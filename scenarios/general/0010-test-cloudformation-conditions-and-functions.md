# Basic localstack functionality tests

The CloudFormation stack deployments tests the ability to select various parameter options based non certain conditions. It's a good way to test your `localstack` configuration.

# Data Preparation

Run the following to store a SSM parameter value:

```shell
aws ssm put-parameter --name test1 --value test-value-1 --type String  --profile $PROFILE
```

Expected output:

```json
{
    "Version": 1
}
```

Test that the parameter actually works:

```shell
aws ssm get-parameter --name test1 --profile $PROFILE --query "Parameter.Value" --output text
```

The command should return the text `test-value-1`.

# Deployment

Run:

```shell
# Test 1: Use the default option
TEMPLATE_BODY="file://$PWD/cloudformation/simple-feature-test-for-conditions-and-functions.yaml" && \
aws cloudformation create-stack \
--stack-name test-0010-default-option \
--template-body $TEMPLATE_BODY \
--profile $PROFILE

# Test 2: Use the override option
PARAM_VALUE="ParameterKey=SsmParameterValueOverrideParam,ParameterValue=test-value-2" && \
TEMPLATE_BODY="file://$PWD/cloudformation/simple-feature-test-for-conditions-and-functions.yaml" && \
aws cloudformation create-stack \
--stack-name test-0010-override-option \
--template-body $TEMPLATE_BODY \
--parameters $PARAM_VALUE \
--profile $PROFILE
```

# Verification

## Coverage

Last Test:

| Meta Data             | Value                                                                                   |
|-----------------------|-----------------------------------------------------------------------------------------|
| Tested Date           | `2023-12-26`                                                                            |
| localstack version    | `3.0.3.dev`                                                                             |
| AWS CLI version       | `aws-cli/2.7.29 Python/3.9.11 Linux/6.5.0-10010-tuxedo exe/x86_64.ubuntu.22 prompt/off` |
| localstack deployment | `Worked` and `Verifications Passed`                                                     |
| AWS deployment        | `Worked` and `Verifications Passed`                                                     |

## Verify CloudFormation stacks where created

Run:

```shell
aws cloudformation list-stacks --profile $PROFILE --output json | jq -r ".StackSummaries[] | [.StackName, .StackStatus] | @csv" | grep "test-0010-"
```

Expected output:

```text
"test-0010-default-option","CREATE_COMPLETE"
"test-0010-override-option","CREATE_COMPLETE"
```

## Verify exports

Run:

```shell
aws cloudformation list-exports --profile $PROFILE --output json | jq -r ".Exports[] | [.Name, .Value] | @csv" | grep "test-0010-"
```

Expected output:

```text
"test-0010-default-option-SecretDataArn","arn:aws:secretsmanager:us-east-1:000000000000:secret:test-0010-default-option-LocalstackCloudFormationTest-yBTBOQ"
"test-0010-override-option-SecretDataArn","arn:aws:secretsmanager:us-east-1:000000000000:secret:test-0010-override-option-LocalstackCloudFormationTest-DlsRVQ"
```

> [!IMPORTANT]
> Use the ARN from the output in the following verification steps to retrieve the values

## Verify by retrieving the stored values from SecretsManager

Retrieve the default value (value expected to be `test-value-1`):

```shell
aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-1:000000000000:secret:test-0010-default-option-LocalstackCloudFormationTest-yBTBOQ --profile $PROFILE --query "SecretString" --output text
```

The override value must be `test-value-2`:

```shell
aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-1:000000000000:secret:test-0010-override-option-LocalstackCloudFormationTest-DlsRVQ --profile $PROFILE --query "SecretString" --output text
```
