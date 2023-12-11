# EKS Node Base

Deploy the base stack that each EKS Node group will reference.

## Deployment

Run:

```shell
EKS_CLUSTER_VERSION="1.24" && \
NODE_AMI=`aws ssm get-parameter --name /aws/service/eks/optimized-ami/${EKS_CLUSTER_VERSION}/amazon-linux-2/recommended/image_id --query "Parameter.Value" --output text --profile localstack` && \
EKS_ENDPOINT_URL=`aws eks describe-cluster --name cluster1 --profile localstack | jq -r ".cluster.endpoint"` && \
EKS_CERTIFICATE_DATA=`aws eks describe-cluster --name cluster1 --profile localstack | jq -r ".cluster.certificateAuthority.data"` && \
PARAM_VALUE_1="ParameterKey=EksClusterNameParam,ParameterValue=cluster1" && \
PARAM_VALUE_2="ParameterKey=EksClusterEndPointUrlParam,ParameterValue=${EKS_ENDPOINT_URL}" && \
PARAM_VALUE_3="ParameterKey=EksClusterCertificateDataParam,ParameterValue=${EKS_CERTIFICATE_DATA}" && \
PARAM_VALUE_4="ParameterKey=ImageIdOverrideParam,ParameterValue=${NODE_AMI}" && \
TEMPLATE_BODY="file://$PWD/cloudformation/eks-private-cluster-nodes-base.yaml" && \
aws cloudformation create-stack \
--stack-name eks-cluster-node-base \
--template-body $TEMPLATE_BODY \
--parameters $PARAM_VALUE_1 $PARAM_VALUE_2 $PARAM_VALUE_3 $PARAM_VALUE_4 \
--profile localstack
```

## Verification

### List Launch Templates

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

rm -vf $KUBECONFIG && aws eks update-kubeconfig --name cluster1 --kubeconfig $KUBECONFIG --profile nicc777

kubectl get nodes
```

Expected Output:

```text
NAME                    STATUS   ROLES                  AGE     VERSION
k3d-cluster1-server-0   Ready    control-plane,master   2m18s   v1.24.13+k3s1
```

