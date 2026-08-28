#!/bin/bash
# Usage: ./deploy.sh [bucket-name]

set -e

BUCKET_NAME=${1:-"student-website-$(date +%s)"}
REGION="eu-north-1"

echo "Bucket: $BUCKET_NAME"
echo "Region: $REGION"

if aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'
then
    aws s3 mb s3://$BUCKET_NAME --region $REGION

    aws s3api put-public-access-block \
        --bucket $BUCKET_NAME \
        --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

    sed "s/BUCKET_NAME/$BUCKET_NAME/g" bucket-policy.json > /tmp/bucket-policy-temp.json
    aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file:///tmp/bucket-policy-temp.json
    rm /tmp/bucket-policy-temp.json

    aws s3 website s3://$BUCKET_NAME/ --index-document index.html --error-document error.html
fi

aws s3 sync website/ s3://$BUCKET_NAME/ --delete

echo "http://$BUCKET_NAME.s3-website.$REGION.amazonaws.com"

aws s3 ls s3://$BUCKET_NAME/ --recursive --human-readable
