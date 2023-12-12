# EKS Node Base

Enable policies to allow EC2 instance access via SSM.

## Deployment

Run:

```shell
TEMPLATE_BODY="file://$PWD/cloudformation/ec2-ssm.yaml" && \
aws cloudformation create-stack \
--stack-name ec2-ssm-feature \
--template-body $TEMPLATE_BODY \
--profile localstack
```

## Verification

### List Created Resources

Run

```shell
aws cloudformation describe-stack-resources --stack-name ec2-ssm-feature --profile localstack | jq ".StackResources[] | {ResourceType, PhysicalResourceId, ResourceStatus}"
```

Expected output:

```json
{
  "ResourceType": "AWS::IAM::Role",
  "PhysicalResourceId": "ec2-ssm-feature-Ec2AccessViaSsmRole-7a3b9b5c",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::IAM::ManagedPolicy",
  "PhysicalResourceId": "arn:aws:iam::000000000000:policy/ec2-ssm-feature-Ec2AccessViaSsmPolicy-0063087f",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::IAM::InstanceProfile",
  "PhysicalResourceId": "ec2-ssm-feature-Ec2AccessViaSsmInstanceP-2548298f",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::SecurityGroup",
  "PhysicalResourceId": "sg-2ad17f890ec9a4019",
  "ResourceStatus": "CREATE_COMPLETE"
}
```

### List Exports

Run:

```shell
aws cloudformation list-exports --profile localstack
```

Expected Output:

```json
{
    "Exports": [
        {
            "ExportingStackId": "arn:aws:cloudformation:us-east-1:000000000000:stack/ec2-ssm-feature/a6ee5104",
            "Name": "Ec2AccessViaSsmInstanceProfileArn",
            "Value": "arn:aws:iam::000000000000:instance-profile/ec2-ssm-feature-Ec2AccessViaSsmInstanceP-2548298f"
        },
        {
            "ExportingStackId": "arn:aws:cloudformation:us-east-1:000000000000:stack/ec2-ssm-feature/a6ee5104",
            "Name": "Ec2AccessViaSsmSecurityGroup",
            "Value": "sg-2ad17f890ec9a4019"
        },
        {
            "ExportingStackId": "arn:aws:cloudformation:us-east-1:000000000000:stack/ec2-ssm-feature/a6ee5104",
            "Name": "Ec2AccessViaSsmPolicyArn",
            "Value": "arn:aws:iam::000000000000:policy/ec2-ssm-feature-Ec2AccessViaSsmPolicy-0063087f"
        }
    ]
}
```
