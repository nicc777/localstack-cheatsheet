#!/bin/sh

###############################################################################
###                                                                         ###
###     Parse Command Line Arguments                                        ###
###                                                                         ###
###############################################################################

show_help () {
    # FIXME
    echo "Useful Help Message..."
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
output_file=""
verbose=0

while getopts "h?vf:" opt; do
  case "$opt" in
    h|\?)
      show_help
      exit 0
      ;;
    v)  verbose=1
      ;;
    f)  output_file=$OPTARG
      ;;
  esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift


###############################################################################
###                                                                         ###
###     Localstack Init                                                     ###
###                                                                         ###
###############################################################################

# TODO - I still need to make this optional...

. venv/bin/activate
export PATH=$PATH:$PWD/opt/bin:$PWD/venv/bin

# alias aws='$PWD/opt/bin/aws --endpoint-url=http://localhost:4566'
alias aws='$PWD/opt/bin/aws'

# export PROFILE=localstack
export PROFILE=nicc777

###############################################################################
###                                                                         ###
###     Deploy                                                              ###
###                                                                         ###
###############################################################################

# TODO "fsx" and others should be optional? Perhaps receive the list via parameters...
# Original list: fsx sts secretsmanager logs elasticloadbalancing ecr.dkr ecr.api ec2 autoscaling cloudformation ebs eks xray
for ENDPOINT_TYPE in sts secretsmanager logs elasticloadbalancing ecr.dkr ecr.api ec2 autoscaling cloudformation ebs eks
do
    echo "Provisioning ${ENDPOINT_TYPE} VPC Endpoint"
    ENDPOINT_TYPE_NAME=`echo $ENDPOINT_TYPE | tr "." -`
    PARAM_VALUE="ParameterKey=ServiceEndpointNameParam,ParameterValue=${ENDPOINT_TYPE}" && \
    STACK_NAME="vpc-endpoint-interface-${ENDPOINT_TYPE_NAME}" && \
    TEMPLATE_BODY="file://$PWD/cloudformation/vpc-endpoint-interface-type.yaml" && \
    AWS_PAGER="" aws cloudformation create-stack \
        --stack-name $STACK_NAME \
        --template-body $TEMPLATE_BODY \
        --parameters $PARAM_VALUE \
        --profile $PROFILE
    sleep 30
done

ENDPOINT_TYPE="s3" && \
PARAM_VALUE="ParameterKey=ServiceEndpointNameParam,ParameterValue=${ENDPOINT_TYPE}" && \
STACK_NAME="vpc-endpoint-interface-${ENDPOINT_TYPE}" && \
TEMPLATE_BODY="file://$PWD/cloudformation/vpc-endpoint-gateway-type.yaml" && \
AWS_PAGER="" aws cloudformation create-stack \
--stack-name $STACK_NAME \
--template-body $TEMPLATE_BODY \
--parameters $PARAM_VALUE \
--profile $PROFILE


