# EKS Node Base

The following CloudFOrmation stack tests the ability to select various parameter options based non certain conditions.

## Deployment

Run:

```shell
# Test 1: Use the default option
TEMPLATE_BODY="file://$PWD/cloudformation/simple-feature-test-for-conditions-and-functions.yaml" && \
aws cloudformation create-stack \
--stack-name test-0010-default-option \
--template-body $TEMPLATE_BODY \
--profile localstack

# Test 2: Use the override option
PARAM_VALUE="ParameterKey=ImageIdOverrideParam,ParameterValue=ami-testtest" && \
TEMPLATE_BODY="file://$PWD/cloudformation/simple-feature-test-for-conditions-and-functions.yaml" && \
aws cloudformation create-stack \
--stack-name test-0010-override-option \
--template-body $TEMPLATE_BODY \
--parameters $PARAM_VALUE \
--profile localstack
```

## Verification

TODO