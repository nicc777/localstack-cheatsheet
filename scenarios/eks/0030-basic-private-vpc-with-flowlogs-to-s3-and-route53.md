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
--parameters ParameterKey=BucketNameParam,ParameterValue=nicc777-example-flowlogs \
--capabilities CAPABILITY_IAM \
--profile localstack

# Create the VPC
TEMPLATE_BODY="file://$PWD/cloudformation/vpc-private-with-route53.yaml" && \
PARAMETERS_FILE="file://$PWD/parameters/vpc-private-with-route53-params.json" && \
aws cloudformation create-stack \
--stack-name vpc-base \
--template-body $TEMPLATE_BODY \
--parameters $PARAMETERS_FILE \
--profile localstack

# Route 53 entries for DNS - see https://docs.localstack.cloud/user-guide/aws/route53/#customizing-internal-endpoint-resolution
zone_id=$(aws route53 create-hosted-zone \
    --name localhost.localstack.cloud \
    --caller-reference r1 \
    --profile localstack | jq -r .HostedZone.Id)

# Adapt the 192.168.2.18 address below to the LAN IP Address of the host running localstack
aws route53 change-resource-record-sets \
    --hosted-zone-id $zone_id \
    --profile localstack \
    --change-batch '{"Changes":[{"Action":"CREATE","ResourceRecordSet":{"Name":"localhost.localstack.cloud","Type":"A","ResourceRecords":[{"Value":"192.168.2.18"}]}},{"Action":"CREATE","ResourceRecordSet":{"Name":"*.localhost.localstack.cloud","Type":"A","ResourceRecords":[{"Value":"192.168.2.18"}]}}]}'

localstack dns systemd-resolved

###
### NOTE : When you are done, remember to run: prompt> localstack dns systemd-resolved --revert
###
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

### DNS COnfirmation

Run:

```shell
dig @127.0.0.1 localhost.localstack.cloud
```

Expected output:

```text
; <<>> DiG 9.18.18-0ubuntu0.22.04.1-Ubuntu <<>> @127.0.0.1 localhost.localstack.cloud
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 42181
;; flags: qr aa rd ra ad; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;localhost.localstack.cloud.    IN      A

;; ANSWER SECTION:
localhost.localstack.cloud. 300 IN      A       192.168.2.18

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sun Dec 24 07:22:10 CET 2023
;; MSG SIZE  rcvd: 60
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
