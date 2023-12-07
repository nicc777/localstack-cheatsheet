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
            "CertificateArn": "arn:aws:acm:us-east-1:000000000000:certificate/47a78bd4-f037-4c58-a1a7-3b2de16a757a",
            "DomainName": "*..example.tld",
            "SubjectAlternativeNameSummaries": [
                "*..example.tld"
            ],
            "HasAdditionalSubjectAlternativeNames": false,
            "Status": "ISSUED",
            "Type": "AMAZON_ISSUED",
            "KeyAlgorithm": "RSA-2048",
            "KeyUsages": [
                "DIGITAL_SIGNATURE",
                "KEY_ENCIPHERMENT"
            ],
            "ExtendedKeyUsages": [
                "TLS_WEB_SERVER_AUTHENTICATION",
                "TLS_WEB_CLIENT_AUTHENTICATION"
            ],
            "InUse": false,
            "RenewalEligibility": "INELIGIBLE",
            "NotBefore": "2023-12-07T06:33:13+01:00",
            "NotAfter": "2024-12-06T06:33:13+01:00",
            "CreatedAt": "2023-12-07T06:33:13.657946+01:00",
            "IssuedAt": "2023-12-07T06:33:13.657946+01:00"
        }
    ]
}
```
