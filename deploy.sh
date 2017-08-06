#!/bin/bash

MYIP=`dig +short myip.opendns.com @resolver1.opendns.com`
AWS_ACCOUNT_NUM=`aws ec2 describe-security-groups \
                    --group-names 'Default' \
                    --query 'SecurityGroups[0].OwnerId' \
                    --output text`

echo ">>> Creating deployment bucket..."
aws s3api create-bucket --bucket my-kafka-deployment-${AWS_ACCOUNT_NUM} --region us-east-1 --acl public-read

echo ">>> Updating deployment bucket policies..."
sed "s/MyDeploymentBucket/my-kafka-deployment-${AWS_ACCOUNT_NUM}/g" policy_template.json > policy.json
aws s3api put-bucket-policy --bucket my-kafka-deployment-${AWS_ACCOUNT_NUM} --policy file://./policy.json
rm policy.json

echo ">>> Uploading nodegroup template..."
aws s3 cp nodegroup.template s3://my-kafka-deployment-${AWS_ACCOUNT_NUM}/confluent-kafka/templates/nodegroup.template

echo ">>> Uploading scripts..."
aws s3 cp cf-kafka-cluster-scripts/ s3://my-kafka-deployment-${AWS_ACCOUNT_NUM}/confluent-kafka/scripts/ --recursive

echo ">>> Deploying kafka stack..."
aws cloudformation create-stack --stack-name kafka --template-body file://./cf-kafka-cluster.yml --parameters ParameterKey=SubnetID,ParameterValue=subnet-0c219220 ParameterKey=VPCID,ParameterValue=vpc-1491216d ParameterKey=SSHAccessCIDR,ParameterValue=${MYIP}/32 ParameterKey=RemoteAccessCIDR,ParameterValue=${MYIP}/32  --capabilities CAPABILITY_IAM
