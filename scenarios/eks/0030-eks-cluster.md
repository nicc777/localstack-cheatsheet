# EKS Cluster

Deploy the EKS cluster.

> **Note**
> To choose the EKS cluster version, refer to https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html - however, this should have no effect in localstack.

## Deployment

Run:

```shell
EKS_CLUSTER_VERSION="1.24" && \
PARAM_VALUE="ParameterKey=EksClusterVersionParam,ParameterValue=${EKS_CLUSTER_VERSION}" && \
TEMPLATE_BODY="file://$PWD/cloudformation/eks-private-cluster.yaml" && \
aws cloudformation create-stack \
--stack-name eks-cluster \
--template-body $TEMPLATE_BODY \
--parameters $PARAM_VALUE \
--capabilities CAPABILITY_NAMED_IAM \
--profile $PROFILE
```

## Verification

### List Created Resources

Run

```shell
aws cloudformation describe-stack-resources --stack-name eks-cluster --profile $PROFILE | jq ".StackResources[] | {ResourceType, PhysicalResourceId, ResourceStatus}"

# Alternative, more compact output:
aws cloudformation describe-stack-resources --stack-name eks-cluster --profile $PROFILE | jq -r ".StackResources[] | [.ResourceType,.PhysicalResourceId,.ResourceStatus] | @csv"
```

Expected Output (while updating):

```json
{
  "ResourceType": "AWS::IAM::Role",
  "PhysicalResourceId": "eks-cluster-ClusterRole",
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::EKS::Cluster",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EKS::Addon",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EKS::Addon",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EKS::Addon",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
{
  "ResourceType": "AWS::EKS::Addon",
  "PhysicalResourceId": null,
  "ResourceStatus": "UPDATE_IN_PROGRESS"
}
```

> [!IMPORTANT]
> It will take a minute or two before all `ResourceStatus` values are `CREATE_COMPLETE`

### List EKS Clusters

Run

```shell
aws eks describe-cluster --name cluster1 --profile $PROFILE 
```

Expected output:

```json
{
    "cluster": {
        "name": "cluster1",
        "arn": "arn:aws:eks:us-east-1:000000000000:cluster/cluster1",
        "createdAt": "2023-12-07T07:38:24.704000+01:00",
        "version": "1.24",
        "roleArn": "arn:aws:iam::000000000000:role/eks-cluster-ClusterRole",
        "resourcesVpcConfig": {
            "subnetIds": [
                "subnet-4063af64",
                "subnet-de10a39e",
                "subnet-09df86e2"
            ],
            "securityGroupIds": [],
            "endpointPublicAccess": false,
            "endpointPrivateAccess": true,
            "publicAccessCidrs": [
                "0.0.0.0/0"
            ]
        },
        "identity": {
            "oidc": {
                "issuer": "https://localhost.localstack.cloud/eks-oidc"
            }
        },
        "status": "CREATING",
        "platformVersion": "eks.5",
        "tags": {}
    }
}
```

### Test Connectivity

Run:

```shell
export KUBECONFIG=$HOME/eksconfig 

rm -vf $KUBECONFIG && aws eks update-kubeconfig --name cluster1 --kubeconfig $KUBECONFIG --profile $PROFILE

kubectl get nodes
```

Expected Output:

```text
NAME                    STATUS   ROLES                  AGE     VERSION
k3d-cluster1-server-0   Ready    control-plane,master   2m18s   v1.24.13+k3s1
```

