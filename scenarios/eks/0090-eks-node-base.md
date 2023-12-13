# EKS Node Base

Deploy the base stack that each EKS Node group will reference.

## Deployment

Run:

```shell
# Prepare the parameters file
rm -vf /tmp/eks-cluster-node-base-parameters.json && \
EKS_CLUSTER_VERSION="1.24" && \
NODE_AMI=`aws ssm get-parameter --name /aws/service/eks/optimized-ami/${EKS_CLUSTER_VERSION}/amazon-linux-2/recommended/image_id --query "Parameter.Value" --output text --profile localstack` && \
EKS_ENDPOINT_URL=`aws eks describe-cluster --name cluster1 --profile localstack | jq -r ".cluster.endpoint"` && \
EKS_CERTIFICATE_DATA=`aws eks describe-cluster --name cluster1 --profile localstack | jq -r ".cluster.certificateAuthority.data"` && \
cat <<EOF >> /tmp/eks-cluster-node-base-parameters.json
[
    {
        "ParameterKey": "EksClusterNameParam",
        "ParameterValue": "cluster1"
    },
    {
        "ParameterKey": "EksClusterEndPointUrlParam",
        "ParameterValue": "${EKS_ENDPOINT_URL}"
    },
    {
        "ParameterKey": "ImageIdOverrideParam",
        "ParameterValue": "${NODE_AMI}"
    },
    {
        "ParameterKey": "EksClusterCertificateDataParam",
        "ParameterValue": "${EKS_CERTIFICATE_DATA}"
    }
]
EOF

# Apply the CloudFormation stack
PARAMETERS_FILE="file:///tmp/eks-cluster-node-base-parameters.json" && \
TEMPLATE_BODY="file://$PWD/cloudformation/eks-private-cluster-nodes-base.yaml" && \
aws cloudformation create-stack \
--stack-name eks-cluster-node-base \
--template-body $TEMPLATE_BODY \
--parameters $PARAMETERS_FILE \
--profile localstack
```

## Verification

### List Created Resources

Run

```shell
aws cloudformation describe-stack-resources --stack-name eks-cluster-node-base --profile localstack | jq ".StackResources[] | {ResourceType, PhysicalResourceId, ResourceStatus}"
```

Expected Output:

```json
{
  "ResourceType": "AWS::IAM::Role",
  "PhysicalResourceId": "eks-cluster-node-base-NodeInstanceRole",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EC2::LaunchTemplate",
  "PhysicalResourceId": "lt-7c61372ec00ecb600",
  "ResourceStatus": "CREATE_COMPLETE"
}
```