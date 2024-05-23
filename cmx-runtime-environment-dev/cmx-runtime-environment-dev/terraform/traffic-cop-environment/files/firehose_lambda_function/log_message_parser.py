import re
from datetime import datetime

def add_event_time(log_time, template):
  if log_time['timestamp']:
     date_time_obj = datetime.strptime(log_time['timestamp'], template.log_datetime_format)
     log_time['eventTime'] = date_time_obj.strftime(template.converted_datatime_format)

def parse_log_message(template, log_message):
  parsed_message = {}
  for key in template.log_template.keys():
     match = re.search(template.log_template[key], log_message)
     #  If-statement after search() tests if it succeeded
     if match:
       parsed_message[key] = match.group(1)

  # adding eventTime field to record is convenient in Kibana to create datetime based
  # search index, if the original 'timestamp' field is NOT ISO format. Kibana/Elasticsearch
  # will not recoganize the field as timestamp.
  add_event_time(parsed_message, template)

  return parsed_message

