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

### List Created Resources

Run

```shell
aws cloudformation describe-stack-resources --stack-name vpc-base --profile localstack | jq ".StackResources[] | {ResourceType, PhysicalResourceId, ResourceStatus}"
```

Expected Output:

```json
{
  "ResourceType": "AWS::EC2::VPC",
  "PhysicalResourceId": "vpc-f0be16df",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::FlowLog",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::NetworkAcl",
  "PhysicalResourceId": "acl-c5f91bc9",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::NetworkAclEntry",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::NetworkAclEntry",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::NetworkAclEntry",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::NetworkAclEntry",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::RouteTable",
  "PhysicalResourceId": "rtb-48ddc617",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::Subnet",
  "PhysicalResourceId": "subnet-6ef3f153",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SubnetNetworkAclAssociation",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SubnetRouteTableAssociation",
  "PhysicalResourceId": "rtbassoc-2dbd114d",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::Subnet",
  "PhysicalResourceId": "subnet-98962faf",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SubnetNetworkAclAssociation",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SubnetRouteTableAssociation",
  "PhysicalResourceId": "rtbassoc-bc067a4e",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::Subnet",
  "PhysicalResourceId": "subnet-297f4731",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SubnetNetworkAclAssociation",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SubnetRouteTableAssociation",
  "PhysicalResourceId": "rtbassoc-15e7aed4",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::Route53::HostedZone",
  "PhysicalResourceId": "/hostedzone/93LJHPPU8EPQUT3",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::DHCPOptions",
  "PhysicalResourceId": "dopt-3d5ea34c",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::VPCDHCPOptionsAssociation",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SecurityGroupEgress",
  "PhysicalResourceId": "-1_None_None",
  "ResourceStatus": "CREATE_COMPLETE"
}
```

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
