# Basic localstack functionality tests

The CloudFormation stack deployments tests the ability to select various parameter options based non certain conditions. It's a good way to test your `localstack` configuration.

## Deployment

Run:

```shell
# Test 1: Use the default option
TEMPLATE_BODY="file://$PWD/cloudformation/simple-feature-test-for-conditions-and-functions.yaml" && \
aws cloudformation create-stack \
--stack-name test-0010-default-option \
--template-body $TEMPLATE_BODY \
--profile $PROFILE

# Test 2: Use the override option
PARAM_VALUE="ParameterKey=ImageIdOverrideParam,ParameterValue=ami-testtest" && \
TEMPLATE_BODY="file://$PWD/cloudformation/simple-feature-test-for-conditions-and-functions.yaml" && \
aws cloudformation create-stack \
--stack-name test-0010-override-option \
--template-body $TEMPLATE_BODY \
--parameters $PARAM_VALUE \
--profile $PROFILE
```

## Verification

<!-- TODO Add verification steps and commands to verify the CloudFormation deployments  -->

> [!NOTE]
> This is still work in progress...