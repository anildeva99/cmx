#!/usr/bin/env python
import boto3
import requests
from requests_aws4auth import AWS4Auth
import sys
import argparse

def get_options(args=sys.argv[1:]):
    parser = argparse.ArgumentParser(description="Parses command.", add_help=False)
    parser.add_argument("-h", "--host", help="Host")
    parser.add_argument("-p", "--port", help="Port")
    parser.add_argument("-d", "--indices", help="Indices to restore.")
    parser.add_argument("-s", "--snapshot", help="Snapshot to restore indices from")
    parser.add_argument("-b", "--bucket", help="S3 bucket, used as elasticsearch repo name")
    parser.add_argument("-r", "--region", help="AWS region for authentication")
    options = parser.parse_args(args)
    return options

options = get_options(sys.argv[1:])

indices = options.indices
snapshot = options.snapshot
bucket = options.bucket
host = options.host
port = options.port
region = options.region

host = 'https://'+ host + ':' + port +'/' # include https:// and trailing /
service = 'es'
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

# Select repository
path = '_snapshot/'+ bucket + '/'+ snapshot + '/_restore'  # the Elasticsearch API endpoint
url = host + path
payload = {"indices": indices}
headers = {"Content-Type": "application/json"}

r = requests.post(url, auth=awsauth, json=payload, headers=headers, verify=False)

print(r.status_code)
print(r.text)
