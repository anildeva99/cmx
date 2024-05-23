#!/usr/bin/env python
import boto3
import requests
from requests_aws4auth import AWS4Auth
import sys
import argparse

############################################################
# This is one-time only s3 repositiory registration code
# Before you run this script, you would first tunnelling to bastion
# and set local es port as 8443
############################################################

def get_options(args=sys.argv[1:]):
    parser = argparse.ArgumentParser(description="Parses command.", add_help=False)
    parser.add_argument("-h", "--host", help="Host")
    parser.add_argument("-p", "--port", help="Port")
    parser.add_argument("-l", "--role", help="AWS role name for elasticsearch")
    parser.add_argument("-b", "--bucket", help="S3 bucket for elasticsearch backup")
    parser.add_argument("-r", "--region", help="AWS region for authentication")
    options = parser.parse_args(args)
    return options

options = get_options(sys.argv[1:])

host = options.host
port = options.port
role = options.role
bucket = options.bucket
region = options.region # e.g. us-east-1

host = 'https://'+ host + ':' + port +'/' # include https:// and trailing /

print (host+'|'+port+'|'+bucket)
service = 'es'
credentials = boto3.Session().get_credentials()
print(credentials.access_key)
print(credentials.secret_key)
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

# Register repository
path = '_snapshot/'+ bucket  # The S3 bucket is used as the elasticsearch "repository" name
url = host + path
payload = {
  "type": "s3",
  "settings": {
    "bucket": bucket,
    "region": region,
    "server_side_encryption": False,
    "role_arn": role
  }
}
headers = {"Content-Type": "application/json"}

r = requests.put(url, auth=awsauth, json=payload, headers=headers, verify=False)

print(r.status_code)
print(r.text)
