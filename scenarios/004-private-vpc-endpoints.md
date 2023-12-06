# Private VPC Endpoint

Private VPC's require endpoints for services in the VPC to communicate with AWS Service API's. 

Several endpoints can be created using a single CloudFOrmation template:

Here are some examples that may typically be required for EKS:

| Endpoint Name          | Type      |
|------------------------|:---------:|
| `fsx`                  | Interface |
| `sqs`                  | Interface |
| `sts`                  | Interface |
| `secretsmanager`       | Interface |
| `logs`                 | Interface |
| `elasticloadbalancing` | Interface |
| `ecr.dkr`              | Interface |
| `ecr.api`              | Interface |
| `ec2`                  | Interface |
| `autoscaling`          | Interface |
| `cloudformation`       | Interface |
| `ebs`                  | Interface |
| `eks`                  | Interface |
| `xray`                 | Interface |
| `s3`                   | Gateway   |

The `s3` endpoint in particular is optimized for EKS to allow pulling of initial containers required by EKS.

## Deployment

### Interface VPC Endpoints

Run the following for each interface type you need:

```shell
# Replace "fsx" below with each Interface type you would like to provision and run the command multiple times...
ENDPOINT_TYPE="fsx" && \
PARAM_VALUE="ParameterKey=ServiceEndpointNameParam,ParameterValue=${ENDPOINT_TYPE}" && \
STACK_NAME="vpc-endpoint-interface-${ENDPOINT_TYPE}" && \
TEMPLATE_BODY="file://$PWD/cloudformation/vpc-endpoint-interface-type.yaml" && \
aws cloudformation create-stack \
--stack-name $STACK_NAME \
--template-body $TEMPLATE_BODY \
--parameters $PARAM_VALUE \
--profile localstack
```

### Gateway VPC Endpoints

Run the following for each interface type you need:

```shell
# Replace "fsx" below with each Interface type you would like to provision and run the command multiple times...
ENDPOINT_TYPE="s3" && \
PARAM_VALUE="ParameterKey=ServiceEndpointNameParam,ParameterValue=${ENDPOINT_TYPE}" && \
STACK_NAME="vpc-endpoint-interface-${ENDPOINT_TYPE}" && \
TEMPLATE_BODY="file://$PWD/cloudformation/vpc-endpoint-gateway-type.yaml" && \
aws cloudformation create-stack \
--stack-name $STACK_NAME \
--template-body $TEMPLATE_BODY \
--parameters $PARAM_VALUE \
--profile localstack
```


## Verification

### List All Endpoints

Run:

```shell
aws ec2 describe-vpc-endpoints --profile localstack
```

Expected output:

```json
{
    "VpcEndpoints": [
        {
            "VpcEndpointId": "vpce-1e5f221b",
            "VpcEndpointType": "Interface",
            "VpcId": "vpc-5f48c6ae",
            "ServiceName": "com.amazonaws.us-east-1.fsx",
            "State": "available",
            "PolicyDocument": "{\"Statement\": [{\"Effect\": \"Allow\", \"Principal\": \"*\", \"Action\": \"*\", \"Resource\": \"*\"}]}",
            "RouteTableIds": [],
            "SubnetIds": [
                "subnet-b9f78ba4",
                "subnet-4908b0ea",
                "subnet-4f34c405"
            ],
            "IpAddressType": "ipv4",
            "DnsOptions": {
                "DnsRecordIpType": "ipv4"
            },
            "PrivateDnsEnabled": true,
            "RequesterManaged": false,
            "NetworkInterfaceIds": [
                "eni-2242be18",
                "eni-a7c5a1db",
                "eni-f7683f21"
            ],
            "DnsEntries": [
                {
                    "DnsName": "vpce-1e5f221b-6570fdde.com.amazonaws.us-east-1.fsx",
                    "HostedZoneId": "4657504DFA4BE"
                }
            ],
            "CreationTimestamp": "2023-12-06T19:00:18+00:00",
            "Tags": [],
            "OwnerId": "000000000000"
        },
        {
            "VpcEndpointId": "vpce-22a27b33",
            "VpcEndpointType": "Gateway",
            "VpcId": "vpc-5f48c6ae",
            "ServiceName": "com.amazonaws.us-east-1.s3",
            "State": "available",
            "PolicyDocument": "{\"Statement\": [{\"Effect\": \"Allow\", \"Principal\": \"*\", \"Action\": \"*\", \"Resource\": [\"arn:aws:s3:::prod-eu-central-1-starport-layer-bucket/*\", \"*\"]}]}",
            "RouteTableIds": [
                "rtb-2d4259de",
                "rtb-31f0f932"
            ],
            "IpAddressType": "ipv4",
            "DnsOptions": {
                "DnsRecordIpType": "ipv4"
            },
            "PrivateDnsEnabled": true,
            "RequesterManaged": false,
            "DnsEntries": [],
            "CreationTimestamp": "2023-12-06T19:08:17+00:00",
            "Tags": [],
            "OwnerId": "000000000000"
        }
    ]
}
```
