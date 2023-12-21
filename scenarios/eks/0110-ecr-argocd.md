# EKS Node Groups

Create an ECR repository for the ArgoCD Image

## Deployment

Run:

```shell
PARAM_VALUE_1="ParameterKey=NameParam,ParameterValue=argocd" && \
TEMPLATE_BODY="file://$PWD/cloudformation/ecr-aws-optional-cross-account-access.yaml" && \
aws cloudformation create-stack \
--stack-name ecr-argocd \
--template-body $TEMPLATE_BODY \
--parameters $PARAM_VALUE_1 \
--profile localstack
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
aws ecr describe-repositories --profile localstack | jq -r ".repositories[].repositoryName"
```

Expected Output:

```text
argocd
```

