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
aws cloudformation describe-stack-resources --stack-name eks-cluster1-nodegroup-az2 --profile localstack | jq ".StackResources[] | {ResourceType, PhysicalResourceId, ResourceStatus}"
```

Expected Output:

```json
{
  "ResourceType": "AWS::EKS::Nodegroup",
  "PhysicalResourceId": "cluster1/eks-cluster1-nodegroup-az2",
  "ResourceStatus": "CREATE_COMPLETE"
}
```

### Confirm EKS Cluster is Really Up

For this test, we will use `kubectl` to confirm there are at least 3x nodes:

```shell
# Get EKS kubernetes configuration
rm -vf $HOME/eksconfig && aws eks update-kubeconfig --name cluster1 --kubeconfig $HOME/eksconfig --endpoint-url=http://localhost:4566 --profile localstack

# Set our configuration environment variable
export KUBECONFIG=$HOME/eksconfig 

# Test EKS
kubectl get nodes
```

Expected output from the last command:

```text
NAME                                              STATUS   ROLES                  AGE     VERSION
k3d-cluster1-server-0                             Ready    control-plane,master   4m4s    v1.24.13+k3s1
k3d-cluster1-agent-eks-cluster1-nodegroup-az1-0   Ready    <none>                 2m30s   v1.24.13+k3s1
k3d-cluster1-agent-eks-cluster1-nodegroup-az2-0   Ready    <none>                 2m10s   v1.24.13+k3s1
k3d-cluster1-agent-eks-cluster1-nodegroup-az3-0   Ready    <none>                 114s    v1.24.13+k3s1
```

### Manually Scale Up

Updated the Node group scaling configuration:

```shell
aws eks update-nodegroup-config --cluster-name cluster1 --nodegroup-name eks-cluster1-nodegroup-az1 --scaling-config minSize=2,maxSize=10,desiredSize=2 --profile localstack
```

Expected output:

```json
{
    "update": {
        "id": "82991f6b",
        "status": "Successful",
        "type": "ConfigUpdate",
        "params": [
            {
                "type": "minSize",
                "value": 2
            },
            {
                "type": "maxSize",
                "value": 10
            },
            {
                "type": "desiredSize",
                "value": 2
            }
        ],
        "createdAt": "2023-12-13T06:51:53.183000+01:00",
        "errors": []
    }
}
```

Confirm:

```shell
aws eks describe-nodegroup --cluster-name cluster1 --nodegroup-name eks-cluster1-nodegroup-az1 --profile localstack
```

Expected output:

```json
{
    "nodegroup": {
        "nodegroupName": "eks-cluster1-nodegroup-az1",
        "nodegroupArn": "arn:aws:eks:us-east-1:000000000000:nodegroup/prod/eks-cluster1-nodegroup-az1/id123",
        "clusterName": "cluster1",
        "createdAt": "2023-12-13T06:37:44.074000+01:00",
        "status": "ACTIVE",
        "scalingConfig": {
            "minSize": 2,
            "maxSize": 10,
            "desiredSize": 2
        },
        "subnets": [
            "subnet-0f62ef56"
        ],
        "nodeRole": "arn:aws:iam::000000000000:role/eks-cluster-node-base-NodeInstanceRole",
        "labels": {},
        "launchTemplate": {
            "version": "1",
            "id": "lt-0023c06a97bfc607d"
        }
    }
}
```

> [!NOTE]
> As observed on 2023-12-13, although the command executed successfully, you won't actually see a change in the number of nodes. Looking at the `localstack` loges, there was an unspecified internal server error. Hopefully this will one day be fixed. At least the API calls are successful and the values are updated appropriately - it is just not executed and applied to the cluster nodes.
