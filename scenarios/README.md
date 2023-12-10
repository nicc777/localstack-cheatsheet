- [Goals and Scenarios](#goals-and-scenarios)
  - [Goal: EKS Deployed in a Private VPC](#goal-eks-deployed-in-a-private-vpc)
- [Other Helpful Commands](#other-helpful-commands)
  - [One-Liners](#one-liners)
- [Caveats and Alternative Approaches](#caveats-and-alternative-approaches)
  - [CloudFormation](#cloudformation)

# Goals and Scenarios

Below is a list of stacks and use cases I will maintain on this repo.

A `scenario` is one or more CloudFormation stacks deployed to provision resources that logically can be grouped together.

Each `scenario` is numbered for easy reference.

A `goal` is a group of scenarios put together to achieve some larger end-goal, for example a deployment of EKS in a private VPC will rely on several `scenarios` to be functional and the order in which these are deployed will matter.

## Goal: EKS Deployed in a Private VPC

| Scenario                                                                    | Description                                                                                                                | Dependencies (Scenarios) |
|:---------------------------------------------------------------------------:|----------------------------------------------------------------------------------------------------------------------------|:------------------------:|
| [0010](./0010-enable-ec2-ssm-access.md)                                     | Enable policies to allow EC2 instance access via SSM.                                                                      | N/A                      |
| [0020](./0020-basic-s3-with-lifecycle-policy.md)                            | Just a single S3 bucket with a configurable lifecycle policy (days after which objects are deleted).                       | N/A                      |
| [0030](./0030-basic-private-vpd-with-flowlogs-to-s3-and-route53.md)         | The aim of this scenario is to deploy a basic private VPC with Route53. It may serve as a base for several other examples. | 0010, 0020               |
| [0050](./0040-add-secondary-cidr-to-private-vpc.md)                         | Adds a secondary CIDR to a Private VPC, which is useful for scenarios where you have a limited VPC CIDR with EKS deployed. | 0030                     |
| [0060](./0050-private-vpc-endpoints.md)                                     | Private VPC's require endpoints for services in the VPC to communicate with AWS Service API's.                             | 0030                     |
| [0070](./0060-domain-certificate.md)                                        | A domain certificate for our Route 53 domain.                                                                              | 0030                     |
| [0080](./0070-eks-security-groups.md)                                       | Security groups required by EKS.                                                                                           | 0030                     |
| [0090](./0080-eks-cluster.md)                                               | Deploy the EKS cluster.                                                                                                    | 0030                     |


# Other Helpful Commands

## One-Liners

| Goal                                                          | Command                                                                                                                |
|---------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| Get the names of all currently deployed CloudFormation stacks | `aws cloudformation list-stacks --profile localstack \| jq -r ".StackSummaries[].StackName"`                           |
| Get the events from a specific CloudFormation stack           | `aws cloudformation describe-stack-events --stack-name SSSSSS --profile localstack`                                    |
| List all exports in CloudFormation                            | `aws cloudformation list-exports --profile localstack`                                                                 |
| List all Prefix Lists in the VPC                              | `aws ec2 describe-prefix-lists --profile localstack`                                                                   |
| List all VPC Endpoints                                        | `aws ec2 describe-vpc-endpoints --profile localstack \| jq ".VpcEndpoints[]" \| jq -r ".ServiceName"`                  |
| Describe the created VPC                                      | `aws ec2 describe-vpcs --profile localstack \| jq '.Vpcs[] \| select(.CidrBlock=="10.10.0.10/24")'`                    |
| List all stacks statuses as CSV data                          | `aws cloudformation describe-stacks --profile localstack \| jq -r ".Stacks[] \| [ .StackName, .StackStatus ] \| @csv"` |

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
