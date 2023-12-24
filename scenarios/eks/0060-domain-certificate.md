# Domain Certificate Linked to Our Route 53 Domain

A domain certificate for our Route 53 domain.  

## Deployment

Run:

```shell
TEMPLATE_BODY="file://$PWD/cloudformation/domain-certificate.yaml" && \
aws cloudformation create-stack \
--stack-name domain-certificate \
--template-body $TEMPLATE_BODY \
--profile localstack
```

## Verification

### List Created Resources

Run for each stack created:

```shell
aws cloudformation describe-stack-resources --stack-name domain-certificate --profile localstack | jq ".StackResources[] | {ResourceType, PhysicalResourceId, ResourceStatus}"
```

Expected Output:

```json
{
  "ResourceType": "AWS::CertificateManager::Certificate",
  "PhysicalResourceId": "arn:aws:acm:us-east-1:000000000000:certificate/e2143bf2-2b04-4708-8be2-bfb4abc1473e",
  "ResourceStatus": "CREATE_COMPLETE"
}
```

### List Certificates

Run

```shell
aws acm list-certificates --profile localstack
```

Expected output:

```json
{
    "CertificateSummaryList": [
        {
            "CertificateArn": "arn:aws:acm:us-east-1:000000000000:certificate/2dd97f74-c5b1-4372-9cd6-b7d7f5d2b32d",
            "DomainName": "*.example.tld",
            "SubjectAlternativeNameSummaries": [
                "*.example.tld"
            ],
            "HasAdditionalSubjectAlternativeNames": false,
            "Status": "PENDING_VALIDATION",
            "Type": "AMAZON_ISSUED",
            "KeyAlgorithm": "RSA-2048",
            "KeyUsages": [],
            "ExtendedKeyUsages": [],
            "InUse": false,
            "RenewalEligibility": "INELIGIBLE",
            "CreatedAt": "2023-12-07T06:40:47.997740+01:00"
        }
    ]
}
```
