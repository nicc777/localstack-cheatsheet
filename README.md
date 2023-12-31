
- [localstack-cheatsheet](#localstack-cheatsheet)
- [Update History](#update-history)
- [Before you begin...](#before-you-begin)
- [Start a clean environment](#start-a-clean-environment)
- [Reset A running Environment](#reset-a-running-environment)
- [Example Stacks and Use Cases](#example-stacks-and-use-cases)


# localstack-cheatsheet

Cheatsheet I use myself for testing new AWS development locally using [_localstack_](https://www.localstack.cloud/).

# Update History

| Date       | Status                                                               | Milestones                                                                                                                                             |
|:----------:|----------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|
| 2023-12-22 | <li>`localstack`: not yet working</li><li>`AWS`: Untested</li>       | Created most of the key scripts and instructions to create a Private EKS Cluster                                                                       |
| 2023-12-24 | <li>`localstack`: mostly working</li><li>`AWS`: Untested</li>        | Refer to [this issue](https://github.com/nicc777/localstack-cheatsheet/issues/1)                                                                       |
| 2023-12-25 | <li>`localstack`: mostly working</li><li>`AWS`: mostly working</li>  | Refer to [this issue](https://github.com/nicc777/localstack-cheatsheet/issues/1). See below for details                                                |
| 2023-12-26 | <li>`localstack`: mostly working</li><li>`AWS`: mostly working</li>  | Similar status to the previous day, but the documentation was re-organized and tidied up in preparation for some new scenarios that will now be added. |

AWS State as on 2023-12-25:

* The `FSX` VPC Endpoint failes to deploy with an error in CloudFOrmation that reads: `The VPC endpoint service com.amazonaws.us-east-1.fsx does not support the availability zone of the subnet: subnet-nnnnnnnnnnnn`. Currently looking at [this documentation page](https://repost.aws/knowledge-center/interface-endpoint-availability-zone) for finding a solution
* The `ACM` certificate fails to create - one of [the following problems](https://repost.aws/questions/QU6U3C6whsS-eFnYu4OUsNFg/requesting-acm-acm-not-generating-cert-for-my-loadbalancer-dns) may be causing it. It is not critical at the moment.

# Before you begin...

Remember to set the global environment variable to specify the profile.

```shell
export PROFILE=localstack
```

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
aws sts get-caller-identity --profile $PROFILE
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

Please refer to the page about [Goals and Scenarios](./scenarios/README.md) for a list of currently maintained deployments for `localstack` that will simulate real life goals and scenarios.


