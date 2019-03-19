#!/usr/bin/env bash

AWS_REGION="eu-west-1"
AWS_PROFILE="intapp-devopssbx_eddy.snow@intapp.com"
VPC_STACK_NAME="byocm-vpc"

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
