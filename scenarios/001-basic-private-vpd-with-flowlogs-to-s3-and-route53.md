# Private VPC and Route 53

The aim of this scenario is to deploy a basic private VPC with Route53. It may serve as a base for several other examples.

## Deployment

Run:

```shell
# If not before, create the S3 bucket for the flow logs
TEMPLATE_BODY="file://$PWD/cloudformation/s3-bucket-with-object-expiry.yaml" && \
aws cloudformation create-stack \
--stack-name flowlog-bucket \
--template-body $TEMPLATE_BODY \
--parameters ParameterKey=BucketNameParam,ParameterValue=example-flowlogs \
--profile localstack

# Create the VPC
TEMPLATE_BODY="file://$PWD/cloudformation/vpc-private-with-route53.yaml" && \
PARAMETERS_FILE="file://$PWD/parameters/vpc-private-with-route53-params.json" && \
aws cloudformation create-stack \
--stack-name vpc-base \
--template-body $TEMPLATE_BODY \
--parameters $PARAMETERS_FILE \
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
            "CreationDate": "2023-12-06T14:26:28+00:00"
        }
    ],
    "Owner": {
        "DisplayName": "webfile",
        "ID": "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a"
    }
}
```

### List VPC's

Run

```shell
aws ec2 describe-vpcs --profile localstack
```

Expected output:

```json
{
    "Vpcs": [
        {
            "CidrBlock": "172.31.0.0/16",
            "DhcpOptionsId": "default",
            "State": "available",
            "VpcId": "vpc-ad02f041",
            "OwnerId": "000000000000",
            "InstanceTenancy": "default",
            "Ipv6CidrBlockAssociationSet": [],
            "CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-1e82982b",
                    "CidrBlock": "172.31.0.0/16",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                }
            ],
            "IsDefault": true,
            "Tags": []
        },
        {
            "CidrBlock": "10.10.0.10/24",
            "DhcpOptionsId": "default",
            "State": "available",
            "VpcId": "vpc-00b7e9c5",
            "OwnerId": "000000000000",
            "InstanceTenancy": "default",
            "Ipv6CidrBlockAssociationSet": [],
            "CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-9cf7dc34",
                    "CidrBlock": "10.10.0.10/24",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                }
            ],
            "IsDefault": false,
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "private_vpc"
                }
            ]
        }
    ]
}
```
