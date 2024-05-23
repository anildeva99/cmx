"""
For processing data sent to Firehose by Cloudwatch Logs subscription filters.

Cloudwatch Cloud Trail Logs sends to Firehose records that look like this:

{
  "messageType": "DATA_MESSAGE",
  "owner": "123456789012",
  "logGroup": "log_group_name",
  "logStream": "log_stream_name",
  "subscriptionFilters": [
    "subscription_filter_name"
  ],
  "logEvents": [
    {
      "id": "01234567890123456789012345678901234567890123456789012345",
      "timestamp": 1510109208016,
      "message": "log message 1"
    },
    {
      "id": "01234567890123456789012345678901234567890123456789012345",
      "timestamp": 1510109208017,
      "message": "log message 2"
    }
    ...
  ]
}

   And postgresql logs are in plain text format like this one:

2020-08-24 16:54:05 UTC:10.52.102.23(35944):dictionaryservice@dictionaryservice:[18155]:STATEMENT:  SELECT COUNT(*) FROM public.databasechangeloglock
The data is additionally compressed with GZIP.

We will convert this plain text message into JSON formated message.

The code below will:

1) Gunzip the data
2) Parse the json
3) Set the result to ProcessingFailed for any record whose messageType is not DATA_MESSAGE, thus redirecting them to the
   processing error output. Such records do not contain any log events. You can modify the code to set the result to
   Dropped instead to get rid of these records completely.
4) For records whose messageType is DATA_MESSAGE, extract the individual log events from the logEvents field, and pass
   each one to the transformLogEvent method. In transformLog event, if the message is in JSON format,we append a comma
   after each event json record. If the the message is plain text, we load the template from the module which is passed
   in as part of Kinesis Stream name in event object. Then convert the plain text message to JSON fomated message by
   template Class. After that, we continue to process it as it is JSON message.

5) Concatenate the result from (4) together, removed last comma, and and wrap it with 'AllDocuments' JSON object, set
   the result as the data of the record returned to Firehose. Note that this step will not add any delimiters. Delimiters
   should be appended by the logic within the transformLogEvent method.
6) Any additional records which exceed 6MB will be re-ingested back into Firehose.

"""

import base64
import json
import gzip
import StringIO
import boto3
import imp
import sys
from log_message_parser import parse_log_message
import importlib

def is_json(myjson):
  """ validate json string
  """
  try:
    json_object = json.loads(myjson)
  except ValueError as e:
    return False
  return True

def get_template_name (stream_name):
    return stream_name.split('_to_')[1]+'_log_template'

# dynamic import class of a module
def dynamic_import(name, class_name):

    # import_module() method is used
    # to find the module and return
    # its description and path
    local_module = None
    local_class = None
    local_instance = None
    try:
        local_module = importlib.import_module(name)
    except ImportError:
        print ("module not found: " + name)

    try:
    # getattr loads the module
    # dynamically ans takes the filepath
    # module and description as parameter
        local_class = getattr(local_module, class_name)
        local_instance = local_class()

    except Exception as e:
        print(e)

    return local_module, local_instance


def transformLogEvent(log_event, stream_name, reingested):
    """Transform each log event.

    The default implementation below just extracts the message and appends a comma to it.
    Also test whether JSON object is valid, if not valid, will drop it.

    Args:
    log_event (dict): The original log event. Structure is {"id": str, "timestamp": long, "message": str}

    Returns:
    str: The transformed log event.
    """
    # Choosing '||' as delimiter is arbitary, but distinguishable enough.
    delimiter = '||'
    if reingested:
       return json.dumps(log_event) + delimiter
    elif is_json(log_event['message']):
       # for message in Json format
       return log_event['message'] + delimiter
    else:
       # for message in plain text, the template file has to contain a class
       # called 'Template', it is dynamically loaded.
       template_package, template_obj = dynamic_import(get_template_name (stream_name), 'Template')
       return json.dumps(parse_log_message(template_obj,
                     log_event['message']))+ delimiter

def processRecords(records, streamName):
    for r in records:
        data = base64.b64decode(r['data'])
        striodata = StringIO.StringIO(data)
        try:
            with gzip.GzipFile(fileobj=striodata, mode='r') as f:
                data = json.loads(f.read())
        except IOError:
            print ('Not a gzipped file')
            continue
        except ValueError:
            print("skip empty message:")
            continue

        recId = r['recordId']
        """
        CONTROL_MESSAGE are sent by CWL to check if the subscription is reachable.
        They do not contain actual data.
        """
        try:
            if 'messageType' not in data.keys():
              # These are reingested messages, won't have 'messageType'' field
              data = ''.join([transformLogEvent(data, streamName, True)])
              yield {
                    'data': data,
                    'result': 'Ok',
                    'recordId': recId
              }
            elif data['messageType'] == 'CONTROL_MESSAGE':
              yield { 'result': 'Dropped', 'recordId': recId }
            elif data['messageType'] == 'DATA_MESSAGE':
              data = ''.join([transformLogEvent(e, streamName, False) for e in data['logEvents']])
              yield {
                'data': data,
                'result': 'Ok',
                'recordId': recId
            }
            else:
              yield {
                'result': 'ProcessingFailed',
                'recordId': recId
            }
        except KeyError:
            print ('Unknown type of data.')


def putRecordsToFirehoseStream(streamName, records, client, attemptsMade, maxAttempts):
    failedRecords = []
    codes = []
    errMsg = ''
    # if put_record_batch throws for whatever reason, response['xx'] will error out, adding a check for a valid
    # response will prevent this
    response = None
    try:
        response = client.put_record_batch(DeliveryStreamName=streamName, Records=records)
    except Exception as e:
        failedRecords = records
        errMsg = str(e)

    # if there are no failedRecords (put_record_batch succeeded), iterate over the response to gather results
    if not failedRecords and response and response['FailedPutCount'] > 0:
        for idx, res in enumerate(response['RequestResponses']):
            # (if the result does not have a key 'ErrorCode' OR if it does and is empty) => we do not need to re-ingest
            if 'ErrorCode' not in res or not res['ErrorCode']:
                continue

            codes.append(res['ErrorCode'])
            failedRecords.append(records[idx])

        errMsg = 'Individual error codes: ' + ','.join(codes)

    if len(failedRecords) > 0:
        if attemptsMade + 1 < maxAttempts:
            print('Some records failed while calling PutRecordBatch to Firehose stream, retrying. %s' % (errMsg))
            putRecordsToFirehoseStream(streamName, failedRecords, client, attemptsMade + 1, maxAttempts)
        else:
            raise RuntimeError('Could not put records after %s attempts. %s' % (str(maxAttempts), errMsg))


def putRecordsToKinesisStream(streamName, records, client, attemptsMade, maxAttempts):
    failedRecords = []
    codes = []
    errMsg = ''
    # if put_records throws for whatever reason, response['xx'] will error out, adding a check for a valid
    # response will prevent this
    response = None
    try:
        response = client.put_records(StreamName=streamName, Records=records)
    except Exception as e:
        failedRecords = records
        errMsg = str(e)

    # if there are no failedRecords (put_record_batch succeeded), iterate over the response to gather results
    if not failedRecords and response and response['FailedRecordCount'] > 0:
        for idx, res in enumerate(response['Records']):
            # (if the result does not have a key 'ErrorCode' OR if it does and is empty) => we do not need to re-ingest
            if 'ErrorCode' not in res or not res['ErrorCode']:
                continue

            codes.append(res['ErrorCode'])
            failedRecords.append(records[idx])

        errMsg = 'Individual error codes: ' + ','.join(codes)

    if len(failedRecords) > 0:
        if attemptsMade + 1 < maxAttempts:
            print('Some records failed while calling PutRecords to Kinesis stream, retrying. %s' % (errMsg))
            putRecordsToKinesisStream(streamName, failedRecords, client, attemptsMade + 1, maxAttempts)
        else:
            raise RuntimeError('Could not put records after %s attempts. %s' % (str(maxAttempts), errMsg))


def createReingestionRecord(isSas, originalRecord):
    if isSas:
        return {'data': base64.b64decode(originalRecord['data']), 'partitionKey': originalRecord['kinesisRecordMetadata']['partitionKey']}
    else:
        return {'data': base64.b64decode(originalRecord['data'])}


def createSplittedReingestionRecord(isSas, recordData, reingestRecord):
    # Gzip the data field
    striodata = StringIO.StringIO()
    with gzip.GzipFile(fileobj=striodata, mode='wb') as f:
        f.write(recordData)
        f.close()
    reingestData = striodata.getvalue()
    if isSas:
        return {'data': reingestData, 'partitionKey': reingestRecord['partitionKey']}
    else:
        return {'data': reingestData}

def getReingestionRecord(isSas, reIngestionRecord):
    if isSas:
        return {'Data': reIngestionRecord['data'], 'PartitionKey': reIngestionRecord['partitionKey']}
    else:
        return {'Data': reIngestionRecord['data']}

def splitRecord(isSas, record, reingestRecord):
    splittedData = record['data'].split('||')
    splittedRecordList = []
    # Because there is '||' at the end of string, last of the list of string will be empty string
    if len(splittedData) > 1:
        record['data'] = base64.b64encode(splittedData[0])
        # Remove ending empty string item
        if not splittedData[-1]:
            splittedData.pop()
        # if record contains more than one log message, reingest the messages from 2 to end.
        if len(splittedData) > 1:
            for each in splittedData[1:]:
                splittedRecordList.append( createSplittedReingestionRecord(isSas, each, reingestRecord))
    return splittedRecordList


def handler(event, context):

    print('Number of records in source event:'+str(len(event['records'])))
    isSas = 'sourceKinesisStreamArn' in event
    streamARN = event['sourceKinesisStreamArn'] if isSas else event['deliveryStreamArn']
    region = streamARN.split(':')[3]
    streamName = streamARN.split('/')[1]
    records = list(processRecords(event['records'], streamName))
    projectedSize = 0
    dataByRecordId = {rec['recordId']: createReingestionRecord(isSas, rec) for rec in event['records']}
    putRecordBatches = []
    recordsToReingest = []
    totalRecordsToBeReingested = 0

    for idx, rec in enumerate(records):
        if rec['result'] != 'Ok':
            continue

        reingestRecordList = []

        reingestRecordList = splitRecord(isSas, rec, dataByRecordId[rec['recordId']])
        for currRec in reingestRecordList:
            totalRecordsToBeReingested += 1
            recordsToReingest.append(
                  getReingestionRecord(isSas, currRec)
              )

    # Split out the record batches into multiple groups, 
    # 500 records at max per group by AWS rule
    while len(recordsToReingest) >= 500:
        putRecordBatches.append(recordsToReingest[0:500])
        recordsToReingest = recordsToReingest[500:]

    if len(recordsToReingest) > 0:
        # add the last batch
        putRecordBatches.append(recordsToReingest)

    # iterate and call putRecordBatch for each group
    recordsReingestedSoFar = 0
    if len(putRecordBatches) > 0:
        client = boto3.client('kinesis', region_name=region) if isSas else boto3.client('firehose', region_name=region)
        for recordBatch in putRecordBatches:
            if isSas:
                putRecordsToKinesisStream(streamName, recordBatch, client, attemptsMade=0, maxAttempts=20)
            else:
                putRecordsToFirehoseStream(streamName, recordBatch, client, attemptsMade=0, maxAttempts=20)
            recordsReingestedSoFar += len(recordBatch)
            print('Reingested %d/%d records out of %d' % (recordsReingestedSoFar, totalRecordsToBeReingested, len(event['records'])))
    else:
        print('No records to be reingested')

    # Tracking infomation
    print('Number of records returned to firehose stream:'+ str(len(records)))
    print('Number of records reingested to firehose stream:'+ str(totalRecordsToBeReingested))

    return {"records": records}
