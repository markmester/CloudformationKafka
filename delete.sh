#!/bin/bash

AWS_ACCOUNT_NUM=`aws ec2 describe-security-groups \
                    --group-names 'Default' \
                    --query 'SecurityGroups[0].OwnerId' \
                    --output text`

echo ">>> Emptying buckets..."
buckets=`aws s3 ls | grep pipeline | awk '{print $3}'`
for bucket in ${buckets}; do
    aws s3 rm s3://${bucket} --recursive
done
aws s3 rm s3://my-kafka-deployment-${AWS_ACCOUNT_NUM} --recursive

echo ">>> Deleting stack..."
aws cloudformation delete-stack --stack-name kafka

echo ">>> Deleting deployment bucket..."
aws s3api delete-bucket --bucket my-kafka-deployment-${AWS_ACCOUNT_NUM} --region us-east-1

echo ">>> Done"

