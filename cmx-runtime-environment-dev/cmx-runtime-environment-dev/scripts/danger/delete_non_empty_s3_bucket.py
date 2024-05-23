#!/usr/bin/python3
import sys
import boto3

bucket = sys.argv[1]
print("Cleaning up bucket " + bucket)

session = boto3.Session()
s3 = session.resource(service_name='s3')
bucket = s3.Bucket(bucket)
bucket.object_versions.delete()
bucket.delete()
