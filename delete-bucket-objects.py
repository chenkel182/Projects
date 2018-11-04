#Requires python3, boto3
#Export aws_region & aws_profile before running. Utilizes aws api keys.
#https://boto3.readthedocs.io/en/latest/guide/migrations3.html#deleting-a-bucket

import boto3
session = boto3.Session()
s3 = session.resource(service_name='s3')
#Requests the name of the bucket to delete versioned objects from
bucket_name = input("Insert the name of the s3 bucket: ")
bucket = s3.Bucket(bucket_name)
bucket.object_versions.delete()


##uncomment this if you'd like file names to be printed. Slows down process heavily.
#Prints object name, and ID, then deletes the file
#for b in bucket.object_versions.all():
#	print('Deleting version: {}, ID: {}'.format(b.object_key, b.id))
#	b.delete()
