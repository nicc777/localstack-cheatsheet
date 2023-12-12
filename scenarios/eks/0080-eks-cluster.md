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
--profile localstack
```

## Verification

### List EKS Clusters

Run

```shell
aws eks describe-cluster --name cluster1 --profile localstack 
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

rm -vf $KUBECONFIG && aws eks update-kubeconfig --name cluster1 --kubeconfig $KUBECONFIG --profile localstack

kubectl get nodes
```

Expected Output:

```text
NAME                    STATUS   ROLES                  AGE     VERSION
k3d-cluster1-server-0   Ready    control-plane,master   2m18s   v1.24.13+k3s1
```

