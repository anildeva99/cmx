#!/usr/bin/env python
import boto3
from requests_aws4auth import AWS4Auth
from elasticsearch import Elasticsearch, RequestsHttpConnection
import curator
from datetime import datetime
import json

def delete_old_index(es, kind_string, pattern, days_from_now):
    # Index the test document so that we have an index that matches the timestring pattern.
    # You can delete this line and the test document if you already created some test indices.
    # es.index(index="movies-2017.01.31", doc_type="movie", id="1", body=document)
    index_list = None
    try:
        index_list = curator.IndexList(es)
    except (curator.exceptions.SnapshotInProgress, curator.exceptions.FailedExecution) as e:
        print(e)

    # Filters by age, anything created more than days_from_now ago.
    if index_list.indices:
        index_list.filter_by_regex(kind=kind_string, value=pattern)
        index_list.filter_by_age(source='creation_date', direction='older', unit='days', unit_count=int(days_from_now))
        print(index_list.indices)

    print("Found %s indices to delete" % len(index_list.indices))

    # If our filtered list contains any indices, delete them.
    try:
      if index_list and index_list.indices:
          curator.DeleteIndices(index_list).do_action()

    except (curator.exceptions.SnapshotInProgress, curator.exceptions.FailedExecution) as e:
      print(e)

def deserialize_indices_patterns(indices_in_string):
    index_tokens=indices_in_string.replace("'", "\"").split("},")
    indices_to_delete = []
    for token in index_tokens:
        item = token.replace("[", "").strip().strip(",")+'}'
        obj = None
        try:
            obj = json.loads(item)
        except ValueError as e:
            continue
        indices_to_delete.append(obj)
    return indices_to_delete

def take_snapshot_for_indices(es, repository_name, snapshot_name, wait):
    try:
        # Get the list of indices.
        # You can filter this list if you didn't want to snapshot all indices
        index_list = curator.IndexList(es)
        print('snapshot_name: '+ snapshot_name)

        # Take a new snapshot. This operation can take a while, so we don't want to wait for it to complete.
        if index_list.indices:
            curator.Snapshot(index_list, repository=repository_name, name=snapshot_name, wait_for_completion=wait).do_action()

    except (curator.exceptions.SnapshotInProgress, curator.exceptions.FailedExecution) as e:
        print(e)

# Lambda execution starts here.
def lambda_handler(event, context):
    now = datetime.now()

    # Clunky, but this approach keeps colons out of the URL.
    date_string = '-'.join((str(now.year), str(now.month), str(now.day), str(now.hour), str(now.minute)))
    snapshot_name = 'elasticsearch-applogs-' + date_string
    print('snapshot_name: '+ snapshot_name)

    # Collecting patameters from event
    app_env = event['env']
    indices_to_delete = deserialize_indices_patterns(event['indices_to_delete'])
    elasticsearch_app_domain_host = event['es_domain_name']
    repository_fullname = event['es_repository_name']
    action = event['action']
    region = event['region']

    elasticsearch_host_suffix = '.tc.codametrix.com'
    service = 'es'
    credentials = boto3.Session().get_credentials()
    awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

    # Figure out endpoint of elasticsearch from domain name
    route53_client = boto3.client('route53')
    zone_response = route53_client.list_hosted_zones_by_name(DNSName=app_env + elasticsearch_host_suffix, MaxItems='1')
    hosted_zone_id = zone_response['HostedZones'][0]['Id'].split('/')[2]

    response = route53_client.list_resource_record_sets(
               HostedZoneId = hosted_zone_id,
               StartRecordName = elasticsearch_app_domain_host,
               StartRecordType = 'CNAME',
               MaxItems = '1'
              )

    # Retrieve endpoint of Elesticsearch cluster, so when we send request, we don't have
    # TLS certificate validation.
    elasticsearch_endpoint = response['ResourceRecordSets'][0]['ResourceRecords'][0]['Value']
    print(elasticsearch_endpoint)

    # Build the Elasticsearch client.
    es_client = Elasticsearch(
             hosts = [{'host': elasticsearch_endpoint, 'port': 443}],
             http_auth = awsauth,
             use_ssl = True,
             verify_certs = True,
             connection_class = RequestsHttpConnection,
             timeout = 120 # Deleting snapshots can take a while, so keep the connection open for long enough to get a response.
    )

    # Take snapshot.
    if action and action == 'take_snapshot':
        take_snapshot_for_indices(es_client, repository_fullname, snapshot_name, False)

    if action and action == 'delete_indices':
        for index in indices_to_delete:
            delete_old_index(es_client, index['kind'], index['regex_pattern'], index['days_to_keep'])
