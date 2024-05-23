# These are specific to each log source
log_timestamp_format = '([0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1]) (2[0-3]|[01][0-9]):[0-5][0-9]:[0-5][0-9])'
log_level_exp = '(LOG|DEBUG[0-5]|INFO|NOTICE|WARNING|ERROR|FATAL|PANIC|STATEMENT)'
time_zone_exp = '(UTC|EST)'

# class inside the module 
class Template: 
    # For adding eventTime field to record is convenient in Kibana to create datetime based
    # search index, if the original 'timestamp' field is NOT ISO format. Kibana/Elasticsearch
    # will not recoganize the field as timestamp.
    log_datetime_format = "%Y-%m-%d %H:%M:%S"

    converted_datatime_format = "%Y-%m-%dT%H:%M:%SZ"

    # The fields that will be parsed to JSON files from postgresql logs
    log_template = { 'timestamp': log_timestamp_format,
                 'log_level': log_level_exp,
                 'time_zone': time_zone_exp,
                 'message': ':(' + log_level_exp + ':(.*)?)',
                 'username': '([^:]+)@',
                 'database': '@([^:]+)',
                 'process_id': '\[(\d*[1-9]\d*)\]',
                 'ip': '((\d+)\.(\d+)\.(\d+)\.(\d+))'
                }
