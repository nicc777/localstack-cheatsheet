
- [localstack-cheatsheet](#localstack-cheatsheet)
- [Start a clean environment](#start-a-clean-environment)
- [Reset A running Environment](#reset-a-running-environment)
- [Example Stacks and Use Cases](#example-stacks-and-use-cases)


# localstack-cheatsheet

Cheatsheet I use myself for testing new AWS development locally using [_localstack_](https://www.localstack.cloud/).

# Start a clean environment

Run the following command and follow the instructions:

```shell
./install-or-upgrade.sh
```

All tooling will be installed locally. When you have run `. ./use_localstack` you should also be in the Python virtual environment and the AWS CLI and localstack clients you just installed should be used. You can verify by running:

```shell
# Assuming your are in the local repository directory from where you run the install script and $PWD is now that directory...

which python3
# $PWD/venv/bin/python3

which localstack
# $PWD/venv/bin/localstack

which aws
# aws: aliased to $PWD/opt/bin/aws
```

You may need two or more terminal windows. 

> **Warning**
> You `. ./use_localstack` in each of the terminals

In one terminal run `localstack start`

In another terminal run `localstack status`. Your output may look something like this:

```text
┌─────────────────┬───────────────────────────────────────────────────────┐
│ Runtime version │ 3.0.3.dev                                             │
│ Docker image    │ tag: latest, id: a3ae038efdc2, 📆 2023-12-01T18:59:29 │
│ Runtime status  │ ✔ running (name: "localstack-main", IP: 172.17.0.2)   │
└─────────────────┴───────────────────────────────────────────────────────┘
```

> **Warning**
> If you already have other AWS profiles, just append the text in the examples below to the relevant files.

To prepare a profile, create the following default localstack profile:

File: `~/.aws/credentials`

```text
[localstack]
aws_access_key_id = LKIAQAAAAAAAAPE6DBK4
aws_secret_access_key = Y0dgISUB20332eBAzlmIHRbLZhwr11ltIepU02Up
```

File: `~/.aws/config`

```text
[profile localstack]
region=us-east-1
output=json
cli_pager= 
```

Test:

```shell
aws sts get-caller-identity --profile localstack
```

Output (example):

```json
{
    "UserId": "AKIAIOSFODNN7EXAMPLE",
    "Account": "000000000000",
    "Arn": "arn:aws:iam::000000000000:root"
}
```

# Reset A running Environment

Run the command:

```shell
localstack state reset
```

# Example Stacks and Use Cases

Below is a list of stacks and use cases I will maintain on this repo.

| Scenario                                                                    | Description                                                                                                                | Dependencies (Scenarios) |
|:---------------------------------------------------------------------------:|----------------------------------------------------------------------------------------------------------------------------|:------------------------:|
| [001](./scenarios/001-basic-s3-with-lifecycle-policy.md)                    | Just a single S3 bucket with a configurable lifecycle policy (days after which objects are deleted).                       | N/A                      |
| [002](./scenarios/002-basic-private-vpd-with-flowlogs-to-s3-and-route53.md) | The aim of this scenario is to deploy a basic private VPC with Route53. It may serve as a base for several other examples. | 001                      |
| [003](./scenarios/003-add-secondary-cidr-to-private-vpc.md)                 | Adds a secondary CIDR to a Private VPC, which is useful for scenarios where you have a limited VPC CIDR with EKS deployed. | 002                      |
[ [004](./scenarios/004-private-vpc-endpoints.md)]                            | Private VPC's require endpoints for services in the VPC to communicate with AWS Service API's.                             | 002                      |
| [005](./scenarios/005-domain-certificate.md)                                | A domain certificate for our Route 53 domain.                                                                              | 002                      |



