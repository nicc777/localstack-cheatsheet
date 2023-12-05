#!/usr/bin/env bash

rm -frR venv/
rm -frR opt/
rm -frR aws/
export BASE_DIR=`pwd`

echo "Installing/Upgrading in ${BASE_DIR}"
echo "----------------------------------------"

echo "################################################################################"
echo "###                                                                          ###"
echo "###   Creating Python virtual envioronment                                   ###"
echo "###                                                                          ###"
echo "################################################################################"

python3 -m venv venv
. venv/bin/activate
export PYTHON_VERSION=`python3 --version`

echo "################################################################################"
echo "###                                                                          ###"
echo "###   Installing Localstack                                                  ###"
echo "###                                                                          ###"
echo "################################################################################"

pip3 install --upgrade -r requirements.txt 
export LOCALSTACK_VERSION=`localstack --version`

echo "################################################################################"
echo "###                                                                          ###"
echo "###   Installing AWS CLI                                                     ###"
echo "###                                                                          ###"
echo "################################################################################"

mkdir -p $BASE_DIR/opt/bin $BASE_DIR/opt/aws-cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install --bin-dir $BASE_DIR/opt/bin --install-dir $BASE_DIR/opt/aws-cli --update
export AWS_CLI_VERSION=`$BASE_DIR/opt/bin/aws --version`

echo "################################################################################"
echo "###                                                                          ###"
echo "###   Product Versions                                                       ###"
echo "###                                                                          ###"
echo "################################################################################"
echo
echo "Python Version     : ${PYTHON_VERSION}"
echo "Localstack Version : ${LOCALSTACK_VERSION}" 
echo "AWS CLI Version    : ${AWS_CLI_VERSION}"
echo
echo
echo "   NOTE : Ensure that the LOCALSTACK_AUTH_TOKEN is exported..."
echo
echo
echo "You can now run the following command from your prompt:"
echo
echo "   % . ./use_localstack"
echo
echo

