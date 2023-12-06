# Add s secondary CIDR to a Private VPC

Adds a secondary CIDR to a Private VPC, which is useful for scenarios where you have a limited VPC CIDR with EKS deployed.

## Deployment

Run:

```shell
TEMPLATE_BODY="file://$PWD/cloudformation/vpc-secondary-cidr.yaml" && \
aws cloudformation create-stack \
--stack-name vpc-secondary-cidr \
--template-body $TEMPLATE_BODY \
--profile localstack
```

## Verification

### Describe the VPC

Run

```shell
aws ec2 describe-vpcs --profile localstack | jq '.Vpcs[] | select(.CidrBlock=="10.10.0.10/24")'  
```

Expected output:

```json
{
    "Vpcs": [
        {
            "CidrBlock": "10.10.0.10/24",
            "DhcpOptionsId": "default",
            "State": "available",
            "VpcId": "vpc-5f48c6ae",
            "OwnerId": "000000000000",
            "InstanceTenancy": "default",
            "Ipv6CidrBlockAssociationSet": [],
            "CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-3e885fcc",
                    "CidrBlock": "10.10.0.10/24",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                },
                {
                    "AssociationId": "vpc-cidr-assoc-57090c31",
                    "CidrBlock": "100.64.0.0/16",
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
