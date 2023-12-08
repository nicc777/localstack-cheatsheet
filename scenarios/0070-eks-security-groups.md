# EKS Security Groups

Security groups required by EKS.

AWS Documentation: https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html

## Deployment

Run:

```shell
TEMPLATE_BODY="file://$PWD/cloudformation/eks-private-security-groups.yaml" && \
aws cloudformation create-stack \
--stack-name eks-security-groups \
--template-body $TEMPLATE_BODY \
--profile localstack
```

## Verification


### List Created Resources

Run for each stack created (using FSX below as an example):

```shell
aws cloudformation describe-stack-resources --stack-name eks-security-groups --profile localstack | jq ".StackResources[] | {ResourceType, PhysicalResourceId, ResourceStatus}"
```

Expected Output (Creation in progress):

```json
{
  "ResourceType": "AWS::EC2::PrefixList",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::PrefixList",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::PrefixList",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::PrefixList",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::PrefixList",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::PrefixList",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SecurityGroup",
  "PhysicalResourceId": "sg-75bbf1fa995a22656",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SecurityGroupIngress",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EC2::SecurityGroupIngress",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EC2::SecurityGroupIngress",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EC2::SecurityGroupIngress",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EC2::SecurityGroupIngress",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EC2::SecurityGroupIngress",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EC2::SecurityGroupIngress",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EC2::SecurityGroupEgress",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EC2::SecurityGroupEgress",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EC2::SecurityGroup",
  "PhysicalResourceId": "sg-b6faecf71f163fc16",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SecurityGroupIngress",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EC2::SecurityGroupIngress",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EC2::SecurityGroupIngress",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EC2::SecurityGroupIngress",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EC2::SecurityGroupEgress",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
```

> **Warning**
> You will have to run the command several times and wait until ALL `ResourceStatus` values has a value of `CREATE_COMPLETE`.

### List Security Groups

Run

```shell
# Below may create an error as the API has not been implemented in localstack
VPC_ID=`aws ec2 describe-vpcs --profile localstack | jq '.Vpcs[] | select(.CidrBlock=="10.10.0.10/24")' | jq -r ".VpcId"` && \
aws ec2 get-security-groups-for-vpc --vpc-id $VPC_ID --profile localstack

# This should work:
VPC_ID=`aws ec2 describe-vpcs --profile localstack | jq '.Vpcs[] | select(.CidrBlock=="10.10.0.10/24")' | jq -r ".VpcId"` && \
FILTER="Name=vpc-id,Values=$VPC_ID" && \
aws ec2 describe-security-groups --filter $FILTER --profile localstack
```

Expected output:

```json
{
    "SecurityGroups": [
        {
            "Description": "default VPC security group",
            "GroupName": "default",
            "IpPermissions": [],
            "OwnerId": "000000000000",
            "GroupId": "sg-362f7adc89c2d5ec5",
            "IpPermissionsEgress": [
                {
                    "IpProtocol": "-1",
                    "IpRanges": [
                        {
                            "CidrIp": "0.0.0.0/0"
                        },
                        {
                            "CidrIp": "127.0.0.1/32"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": [],
                    "UserIdGroupPairs": []
                }
            ],
            "Tags": [],
            "VpcId": "vpc-119723bb"
        },
        {
            "Description": "The Cluster Security Group",
            "GroupName": "DnsAndHttpsSecurityGroup",
            "IpPermissions": [],
            "OwnerId": "000000000000",
            "GroupId": "sg-adaf08cd24d4d4cb1",
            "IpPermissionsEgress": [
                {
                    "IpProtocol": "-1",
                    "IpRanges": [
                        {
                            "CidrIp": "0.0.0.0/0"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": [],
                    "UserIdGroupPairs": []
                }
            ],
            "Tags": [],
            "VpcId": "vpc-119723bb"
        },
        {
            "Description": "The Cluster Security Group",
            "GroupName": "EksSecurityGroup",
            "IpPermissions": [],
            "OwnerId": "000000000000",
            "GroupId": "sg-5d60bee522910dadf",
            "IpPermissionsEgress": [
                {
                    "IpProtocol": "-1",
                    "IpRanges": [
                        {
                            "CidrIp": "0.0.0.0/0"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": [],
                    "UserIdGroupPairs": []
                }
            ],
            "Tags": [],
            "VpcId": "vpc-119723bb"
        }
    ]
}
```
