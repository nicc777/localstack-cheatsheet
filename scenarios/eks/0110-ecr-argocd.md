# EKS Node Groups

Create an ECR repository for the ArgoCD Image

You must refer to the [ArgoCD Documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/#tested-versions) to determine which version is most appropriate for your chosen EKS cluster version.

For EKS cluster version 1.24, we will choose ArgoCD Version 2.8.

## Deployment

Below is optimized for ArgoCD Version 2.8 for EKS Version 1.24

Run:

```shell
PARAM_VALUE_1="ParameterKey=NameParam,ParameterValue=argocd" && \
TEMPLATE_BODY="file://$PWD/cloudformation/ecr-aws-optional-cross-account-access.yaml" && \
aws cloudformation create-stack \
--stack-name ecr-argocd \
--template-body $TEMPLATE_BODY \
--parameters $PARAM_VALUE_1 \
--profile localstack

PARAM_VALUE_1="ParameterKey=NameParam,ParameterValue=argocd-dex" && \
TEMPLATE_BODY="file://$PWD/cloudformation/ecr-aws-optional-cross-account-access.yaml" && \
aws cloudformation create-stack \
--stack-name ecr-argocd-dex \
--template-body $TEMPLATE_BODY \
--parameters $PARAM_VALUE_1 \
--profile localstack

PARAM_VALUE_1="ParameterKey=NameParam,ParameterValue=argocd-dex-redis" && \
TEMPLATE_BODY="file://$PWD/cloudformation/ecr-aws-optional-cross-account-access.yaml" && \
aws cloudformation create-stack \
--stack-name ecr-argocd-redis \
--template-body $TEMPLATE_BODY \
--parameters $PARAM_VALUE_1 \
--profile localstack
```

Download the appropriate ArgoCD installation manifest:

```shell
curl -o /tmp/argocd.yaml https://raw.githubusercontent.com/argoproj/argo-cd/v2.8.7/manifests/install.yaml
```

Pull the required images:

```shell
cat /tmp/argocd.yaml | grep "image:" | sort -u | awk -F\: '{print "docker pull"$2}' > /tmp/pull_argocd_images && sh /tmp/pull_argocd_images
```

Next, re-tag and push each of the images to their appropriate ECR repositories:

```shell
# TODO
```

Finally, update the ArgoCD manifest and deploy to EKS:

```shell
# TODO
```


## Verification

### List Created Resources

Run

```shell
aws cloudformation describe-stack-resources --stack-name ecr-argocd --profile localstack | jq ".StackResources[] | {ResourceType, PhysicalResourceId, ResourceStatus}"
```

Expected Output:

```json
{
  "ResourceType": "AWS::ECR::Repository",
  "PhysicalResourceId": null,
  "ResourceStatus": "CREATE_COMPLETE"
}
{
  "ResourceType": "AWS::ECR::Repository",
  "PhysicalResourceId": "argocd",
  "ResourceStatus": "CREATE_COMPLETE"
}
```

### List all ECR repositories

Run:

```shell
aws ecr describe-repositories --profile localstack | jq -r ".repositories[] | [ .repositoryName, .repositoryUri ] | @csv"
```

Expected Output:

```text
"argocd","localhost.localstack.cloud:4511/argocd"
"argocd-dex","localhost.localstack.cloud:4511/argocd-dex"
"argocd-dex-redis","localhost.localstack.cloud:4511/argocd-dex-redis"
```

