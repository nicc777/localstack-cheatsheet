# EKS Node Groups

Deploy a Nodegroup per available subnet

## Deployment

Run:

```shell
# Apply the CloudFormation stack - 3x AZ's
VPC_ID=`aws ec2 describe-vpcs --profile localstack | jq '.Vpcs[] | select(.CidrBlock=="10.10.0.10/24")' | jq -r ".VpcId"` && \
SUBNET_ID=`aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID Name=availability-zone,Values=us-east-1a "Name=tag:Name,Values=vpc_eks_*" --profile localstack | jq -r ".Subnets[].SubnetId"`  && \
PARAM_VALUE_1="ParameterKey=EksClusterNameParam,ParameterValue=cluster1" && \
PARAM_VALUE_2="ParameterKey=SubnetIdParam,ParameterValue=${SUBNET_ID}" && \
TEMPLATE_BODY="file://$PWD/cloudformation/eks-private-cluster-nodes.yaml" && \
aws cloudformation create-stack \
--stack-name eks-cluster1-nodegroup-az1 \
--template-body $TEMPLATE_BODY \
--parameters $PARAM_VALUE_1 $PARAM_VALUE_2 \
--profile localstack

VPC_ID=`aws ec2 describe-vpcs --profile localstack | jq '.Vpcs[] | select(.CidrBlock=="10.10.0.10/24")' | jq -r ".VpcId"` && \
SUBNET_ID=`aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID Name=availability-zone,Values=us-east-1b "Name=tag:Name,Values=vpc_eks_*" --profile localstack | jq -r ".Subnets[].SubnetId"`  && \
PARAM_VALUE_1="ParameterKey=EksClusterNameParam,ParameterValue=cluster1" && \
PARAM_VALUE_2="ParameterKey=SubnetIdParam,ParameterValue=${SUBNET_ID}" && \
TEMPLATE_BODY="file://$PWD/cloudformation/eks-private-cluster-nodes.yaml" && \
aws cloudformation create-stack \
--stack-name eks-cluster1-nodegroup-az2 \
--template-body $TEMPLATE_BODY \
--parameters $PARAM_VALUE_1 $PARAM_VALUE_2 \
--profile localstack

VPC_ID=`aws ec2 describe-vpcs --profile localstack | jq '.Vpcs[] | select(.CidrBlock=="10.10.0.10/24")' | jq -r ".VpcId"` && \
SUBNET_ID=`aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID Name=availability-zone,Values=us-east-1c "Name=tag:Name,Values=vpc_eks_*" --profile localstack | jq -r ".Subnets[].SubnetId"`  && \
PARAM_VALUE_1="ParameterKey=EksClusterNameParam,ParameterValue=cluster1" && \
PARAM_VALUE_2="ParameterKey=SubnetIdParam,ParameterValue=${SUBNET_ID}" && \
TEMPLATE_BODY="file://$PWD/cloudformation/eks-private-cluster-nodes.yaml" && \
aws cloudformation create-stack \
--stack-name eks-cluster1-nodegroup-az3 \
--template-body $TEMPLATE_BODY \
--parameters $PARAM_VALUE_1 $PARAM_VALUE_2 \
--profile localstack
```

## Verification

### List Created Resources

Run

```shell
aws cloudformation describe-stack-resources --stack-name short-term-bucket --profile localstack | jq ".StackResources[] | {ResourceType, PhysicalResourceId, ResourceStatus}"
```

Expected Output:

```json
{
  "ResourceType": "AWS::S3::Bucket",
  "PhysicalResourceId": "st-bucket",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::S3::BucketPolicy",
  "PhysicalResourceId": "9ff7e07c6f58153a59f64d56cd87229a",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::IAM::ManagedPolicy",
  "PhysicalResourceId": "arn:aws:iam::000000000000:policy/short-term-bucket-S3BucketResourceReadPoli-6030b77f",
  "ResourceStatus": "CREATE_COMPLETE"
}
```
