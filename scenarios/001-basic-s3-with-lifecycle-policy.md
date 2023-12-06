# S3 Bucket with life cycle policy

Just a single S3 bucket with a configurable lifecycle policy (days after which objects are deleted).

These buckets are useful when deploying Lambda functions that may require artifacts from S3. The artifacts are only used during initial creation of the resource (Lambda Function ZIP file, for example).

## Deployment

Run:

```shell
TEMPLATE_BODY="file://$PWD/cloudformation/s3-bucket-with-object-expiry.yaml" && \
aws cloudformation create-stack \
--stack-name short-term-bucket \
--template-body $TEMPLATE_BODY \
--parameters ParameterKey=BucketNameParam,ParameterValue=st-bucket \
--profile localstack
```

## Verification

### List Buckets

Run

```shell
aws s3api list-buckets --profile localstack
```

Expected output:

```json
{
    "Buckets": [
        {
            "Name": "example-flowlogs",
            "CreationDate": "2023-12-06T15:09:57+00:00"
        }
    ],
    "Owner": {
        "DisplayName": "webfile",
        "ID": "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a"
    }
}
```

