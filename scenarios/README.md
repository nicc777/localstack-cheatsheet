- [Goals and Scenarios](#goals-and-scenarios)
- [Before Getting Started](#before-getting-started)
  - [Goal: Testing Localstack Capabilities: CloudFormation](#goal-testing-localstack-capabilities-cloudformation)
  - [Goal: Base VPC Deployment](#goal-base-vpc-deployment)
  - [Goal: EKS Deployed in a Private VPC](#goal-eks-deployed-in-a-private-vpc)
  - [Goal: Test some localstack features](#goal-test-some-localstack-features)
- [Helpful Commands](#helpful-commands)
  - [One-Liners](#one-liners)
- [Caveats and Alternative Approaches](#caveats-and-alternative-approaches)
  - [CloudFormation](#cloudformation)
  - [Security Groups with Prefix Lists](#security-groups-with-prefix-lists)

# Goals and Scenarios

Below is a list of stacks and use cases I will maintain on this repo.

A `scenario` is one or more CloudFormation stacks deployed to provision resources that logically can be grouped together.

Each `scenario` is numbered for easy reference.

A `goal` is a group of scenarios put together to achieve some larger end-goal, for example a deployment of EKS in a private VPC will rely on several `scenarios` to be functional and the order in which these are deployed will matter.

# Before Getting Started

Ensure to export the desired profile name to use. For localstack, use the following command:

```shell
export PROFILE=localstack
```

> [!TIP]
> Replace the `localstack` name with one of your real AWS profile names if you would like to run commands against a real AWS account.

## Goal: Testing Localstack Capabilities: CloudFormation

This forms the bases for many other deployments and is usually a dependency for many other goals.

[Link to goal documentation](./general/README.md)

## Goal: Base VPC Deployment

This forms the bases for many other deployments and is usually a dependency for many other goals.

[Link to goal documentation](./vpc-private-with-limited-public-access/README.md)

## Goal: EKS Deployed in a Private VPC

An example of deploying a private EKS cluster (lab environment).

[Link to goal documentation](./eks/README.md)

## Goal: Test some localstack features

Some examples of testing `localstack` features.

[Link to goal documentation](./general/README.md)

# Helpful Commands

## One-Liners

| Goal                                                          | Command                                                                                                                |
|---------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| Get the names of all currently deployed CloudFormation stacks | `aws cloudformation list-stacks --profile $PROFILE \| jq -r ".StackSummaries[].StackName"`                             |
| Get the events from a specific CloudFormation stack           | `aws cloudformation describe-stack-events --stack-name SSSSSS --profile $PROFILE`                                      |
| List all exports in CloudFormation                            | `aws cloudformation list-exports --profile $PROFILE`                                                                   |
| List all Prefix Lists in the VPC                              | `aws ec2 describe-prefix-lists --profile $PROFILE`                                                                     |
| List all VPC Endpoints                                        | `aws ec2 describe-vpc-endpoints --profile $PROFILE \| jq ".VpcEndpoints[]" \| jq -r ".ServiceName"`                    |
| Describe the created VPC                                      | `aws ec2 describe-vpcs --profile $PROFILE \| jq '.Vpcs[] \| select(.CidrBlock=="10.10.0.10/24")'`                      |
| List all stacks statuses as CSV data                          | `aws cloudformation describe-stacks --profile $PROFILE \| jq -r ".Stacks[] \| [ .StackName, .StackStatus ] \| @csv"`   |

# Caveats and Alternative Approaches

Generally it is best to use the same configuration as far as possible. However, this may not always be possible, due to `localstack` limitations.

## CloudFormation

Refer to https://docs.localstack.cloud/user-guide/aws/cloudformation/

Some CloudFormation stacks require the selection of an Availability Zone. Consider the following CloudFormation snippet:

```yaml
  SubnetMainAz1:
    Type: 'AWS::EC2::Subnet'
    Properties:
      AvailabilityZone: !Select [ 0, !GetAZs '' ]
      CidrBlock: !Ref MainSubnetAz1Cidr
      MapPublicIpOnLaunch: False
      VpcId: !Ref Vpc
      Tags:
        - Key: 'Name'
          Value: 'subnet_main_az1'
```

According to the `localstack` documentation (as on 2023-12-09), the Intrinsic Function `Fn::GetAZs` in not yet implemented.

Below is the alternative that was used in the examples (the original lines will remain):

```yaml
  SubnetMainAz1:
    Type: 'AWS::EC2::Subnet'
    Properties:
      # AvailabilityZone: !Select [ 0, !GetAZs '' ]
      AvailabilityZone: !Sub "${AWS::Region}a"
      CidrBlock: !Ref MainSubnetAz1Cidr
      MapPublicIpOnLaunch: False
      VpcId: !Ref Vpc
      Tags:
        - Key: 'Name'
          Value: 'subnet_main_az1'
```

> [!NOTE]
> Above is just one example. Various workarounds may be needed in order to have CloudFormation stacks that would work both in real AWS as well as on `localstack`.

## Security Groups with Prefix Lists

In short, using prefix lists does not really work at all. The end result is that none of the exports would required by other stacks will be available and therefore I had to add a specific `localstack` condition that would use a more general security group configuration that is guaranteed to work under `localstack`.

See the file [cloudformation/eks-private-security-groups.yaml](cloudformation/eks-private-security-groups.yaml) for an example of such a conditional implementation. 
