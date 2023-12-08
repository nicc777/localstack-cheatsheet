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

alias aws='$PWD/opt/bin/aws --endpoint-url=http://localhost:4566'

###############################################################################
###                                                                         ###
###     Deploy                                                              ###
###                                                                         ###
###############################################################################


for ENDPOINT_TYPE in fsx sqs sts secretsmanager logs elasticloadbalancing ecr.dkr ecr.api ec2 autoscaling cloudformation ebs eks xray
do
    echo "Provisioning ${ENDPOINT_TYPE} VPC Endpoint"
    PARAM_VALUE="ParameterKey=ServiceEndpointNameParam,ParameterValue=${ENDPOINT_TYPE}" && \
    STACK_NAME="vpc-endpoint-interface-${ENDPOINT_TYPE}" && \
    TEMPLATE_BODY="file://$PWD/cloudformation/vpc-endpoint-interface-type.yaml" && \
    aws cloudformation create-stack \
        --stack-name $STACK_NAME \
        --template-body $TEMPLATE_BODY \
        --parameters $PARAM_VALUE \
        --profile localstack
    sleep 5
done

ENDPOINT_TYPE="s3" && \
PARAM_VALUE="ParameterKey=ServiceEndpointNameParam,ParameterValue=${ENDPOINT_TYPE}" && \
STACK_NAME="vpc-endpoint-interface-${ENDPOINT_TYPE}" && \
TEMPLATE_BODY="file://$PWD/cloudformation/vpc-endpoint-gateway-type.yaml" && \
aws cloudformation create-stack \
--stack-name $STACK_NAME \
--template-body $TEMPLATE_BODY \
--parameters $PARAM_VALUE \
--profile localstack


