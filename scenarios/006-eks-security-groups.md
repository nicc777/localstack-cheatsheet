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
