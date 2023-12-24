# EKS Node Groups

Create an ECR repository for the ArgoCD Image and then deploy ArgoCD in EKS.

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

PARAM_VALUE_1="ParameterKey=NameParam,ParameterValue=argocd-redis" && \
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
# get the image ID's:
docker image ls | egrep "argocd|dex|redis"

# Tag - adjust in cases where you may have multiple versions of these images...
docker image ls | grep "quay.io/argoproj/argocd" | awk '{print "docker tag "$3" localhost.localstack.cloud:4511/argocd:latest"}' > /tmp/tagging.sh

docker image ls | grep "ghcr.io/dexidp/dex" | awk '{print "docker tag "$3" localhost.localstack.cloud:4511/argocd-dex:latest"}' >> /tmp/tagging.sh

docker image ls | grep "redis" | awk '{print "docker tag "$3" localhost.localstack.cloud:4511/argocd-redis:latest"}' >> /tmp/tagging.sh

sh /tmp/tagging.sh
```

Check the images:

```shell
docker image ls | grep localstack | grep argocd
```

Expected output:

```text
localhost.localstack.cloud:4511/argocd         latest          4785fc1b797e   3 days ago      443MB
localhost.localstack.cloud:4511/argocd-redis   latest          e40e2763392d   2 weeks ago     138MB
localhost.localstack.cloud:4511/argocd-dex     latest          87a000ba044b   8 weeks ago     95.8MB
```

Push the images:

```shell
docker push localhost.localstack.cloud:4511/argocd:latest

docker push localhost.localstack.cloud:4511/argocd-redis:latest

docker push localhost.localstack.cloud:4511/argocd-dex:latest
```

> [!IMPORTANT]
> You do not need to authenticate with the localstack ECR repository, and trying to do so may generate an error. In your automation, you may need to handle this error or entirely skip it if it is a localstack deployment.

Finally, update the ArgoCD manifest and deploy to EKS:

```shell
sed -i 's/image: quay.io\/argoproj\/argocd:v2.8.7/image: localhost.localstack.cloud:4511\/argocd:latest/g' /tmp/argocd.yaml

sed -i 's/image: ghcr.io\/dexidp\/dex:v2.37.0/image: localhost.localstack.cloud:4511\/argocd-dex:latest/g' /tmp/argocd.yaml

sed -i 's/image: redis:7.0.11-alpine/image: localhost.localstack.cloud:4511\/argocd-redis:latest/g' /tmp/argocd.yaml
```

Finally, the manifest can be applied to the EKS cluster:

```shell
kubectl create namespace argocd

kubectl apply -f /tmp/argocd.yaml -n argocd
```

TODO - Address DNS (https://docs.localstack.cloud/user-guide/tools/dns-server/)

TODO - Add ArgoCD to Ingress

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
"argocd-redis","localhost.localstack.cloud:4511/argocd-dex-redis"
```

