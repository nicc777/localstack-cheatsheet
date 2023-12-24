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

### List Created Resources

Run

```shell
aws cloudformation describe-stack-resources --stack-name vpc-secondary-cidr --profile localstack | jq ".StackResources[] | {ResourceType, PhysicalResourceId, ResourceStatus}"
```

Expected Output:

```json
{
  "ResourceType": "AWS::EC2::VPCCidrBlock",
  "PhysicalResourceId": "vpc-cidr-assoc-e9e47bba",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::RouteTable",
  "PhysicalResourceId": "rtb-86fb7d80",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::Subnet",
  "PhysicalResourceId": "subnet-6fd0481e",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SubnetNetworkAclAssociation",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SubnetRouteTableAssociation",
  "PhysicalResourceId": "rtbassoc-da37fe87",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::Subnet",
  "PhysicalResourceId": "subnet-bda04500",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SubnetNetworkAclAssociation",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SubnetRouteTableAssociation",
  "PhysicalResourceId": "rtbassoc-99994964",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::Subnet",
  "PhysicalResourceId": "subnet-6e82649d",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SubnetNetworkAclAssociation",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SubnetRouteTableAssociation",
  "PhysicalResourceId": "rtbassoc-36ac897c",
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
```

### Describe the VPC

Run

```shell
aws ec2 describe-vpcs --profile localstack | jq '.Vpcs[] | select(.CidrBlock=="10.10.0.0/24")'  
```

Expected output:

```json
{
    "Vpcs": [
        {
            "CidrBlock": "10.10.0.0/24",
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
