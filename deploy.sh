#!/usr/bin/env bash

AWS_REGION="eu-west-1"
AWS_PROFILE="intapp-devopssbx_eddy.snow@intapp.com"
PACKAGE_VERSION="$(date +%F_%H%M%S)"
PACKAGE_URL="https://s3-eu-west-1.amazonaws.com/278942993584-eddy-scratch/git/byocm/wordpress/$(echo $PACKAGE_VERSION)_Package.zip"

EC2_KEY_NAME="eddy.snow@intapp-devopssbx"
DOCKER_AMI="ami-07683a44e80cd32c5"
VPC_STACK_NAME="byocm-vpc"
DOCKER_STACK_NAME="byocm-docker"

# Package wordpress solution
echo "[$(date)] - Packaging wordpress solution"

# Package Python functions
zip -r /tmp/$(echo $PACKAGE_VERSION)_Package.zip ./wordpress/*

# Upload package to s3
aws s3 cp /tmp/$(echo $PACKAGE_VERSION)_Package.zip s3://278942993584-eddy-scratch/git/byocm/wordpress/ --profile $AWS_PROFILE

# Deploy AWS Infrastructure
echo "[$(date)] - Deploying stacks to region: $AWS_REGION"

if [ ! $(aws cloudformation describe-stacks --region $AWS_REGION --profile $AWS_PROFILE | jq '.Stacks[].StackName' | grep $VPC_STACK_NAME) ]; then
    echo "[$(date)] - Creating $VPC_STACK_NAME stack"
    aws cloudformation create-stack --stack-name $VPC_STACK_NAME --template-body file://./infrastructure/vpc.yml --profile $AWS_PROFILE --region $AWS_REGION
    aws cloudformation wait stack-create-complete --stack-name $VPC_STACK_NAME --profile $AWS_PROFILE --region $AWS_REGION
else
    echo "[$(date)] - Updating $VPC_STACK_NAME stack"
    aws cloudformation update-stack --stack-name $VPC_STACK_NAME --template-body file://./infrastructure/vpc.yml --profile $AWS_PROFILE --region $AWS_REGION
    aws cloudformation wait stack-update-complete --stack-name $VPC_STACK_NAME --profile $AWS_PROFILE --region $AWS_REGION

fi

if [ ! $(aws cloudformation describe-stacks --region $AWS_REGION --profile $AWS_PROFILE | jq '.Stacks[].StackName' | grep $DOCKER_STACK_NAME) ]; then
    echo "[$(date)] - Creating $DOCKER_STACK_NAME stack"
    aws cloudformation create-stack --stack-name $DOCKER_STACK_NAME --template-body file://./infrastructure/docker-asg.yml --profile $AWS_PROFILE --region $AWS_REGION \
        --parameters \
            ParameterKey=keyName,ParameterValue=$EC2_KEY_NAME \
            ParameterKey=ec2Image,ParameterValue=$DOCKER_AMI \
            ParameterKey=dockerPackageName,ParameterValue=$PACKAGE_URL \
        --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
    aws cloudformation wait stack-create-complete --stack-name $DOCKER_STACK_NAME --profile $AWS_PROFILE --region $AWS_REGION
else
    echo "[$(date)] - Updating $DOCKER_STACK_NAME stack"
    aws cloudformation update-stack --stack-name $DOCKER_STACK_NAME --template-body file://./infrastructure/docker-asg.yml --profile $AWS_PROFILE --region $AWS_REGION \
        --parameters \
            ParameterKey=keyName,ParameterValue=$EC2_KEY_NAME \
            ParameterKey=ec2Image,ParameterValue=$DOCKER_AMI \
            ParameterKey=dockerPackageName,ParameterValue=$PACKAGE_URL \
        --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
    aws cloudformation wait stack-update-complete --stack-name $DOCKER_STACK_NAME --profile $AWS_PROFILE --region $AWS_REGION
fi
