- [Goals and Scenarios](#goals-and-scenarios)
  - [Goal: EKS Deployed in a Private VPC](#goal-eks-deployed-in-a-private-vpc)

# Goals and Scenarios

Below is a list of stacks and use cases I will maintain on this repo.

A `scenario` is one or more CloudFormation stacks deployed to provision resources that logically can be grouped together.

Each `scenario` is numbered for easy reference.

A `goal` is a group of scenarios put together to achieve some larger end-goal, for example a deployment of EKS in a private VPC will rely on several `scenarios` to be functional and the order in which these are deployed will matter.

## Goal: EKS Deployed in a Private VPC

| Scenario                                                                    | Description                                                                                                                | Dependencies (Scenarios) |
|:---------------------------------------------------------------------------:|----------------------------------------------------------------------------------------------------------------------------|:------------------------:|
| [001](./scenarios/001-basic-s3-with-lifecycle-policy.md)                    | Just a single S3 bucket with a configurable lifecycle policy (days after which objects are deleted).                       | N/A                      |
| [002](./scenarios/002-basic-private-vpd-with-flowlogs-to-s3-and-route53.md) | The aim of this scenario is to deploy a basic private VPC with Route53. It may serve as a base for several other examples. | 001                      |
| [003](./scenarios/003-add-secondary-cidr-to-private-vpc.md)                 | Adds a secondary CIDR to a Private VPC, which is useful for scenarios where you have a limited VPC CIDR with EKS deployed. | 002                      |
| [004](./scenarios/004-private-vpc-endpoints.md)                             | Private VPC's require endpoints for services in the VPC to communicate with AWS Service API's.                             | 002                      |
| [005](./scenarios/005-domain-certificate.md)                                | A domain certificate for our Route 53 domain.                                                                              | 002                      |
