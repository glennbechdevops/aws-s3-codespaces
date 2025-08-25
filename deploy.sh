#!/bin/bash

# Deploy script for S3 static website
# Usage: ./deploy.sh [bucket-name]

set -e

BUCKET_NAME=${1:-"student-website-$(date +%s)"}
REGION="eu-north-1"

echo "🚀 Starting deployment to S3..."
echo "Bucket name: $BUCKET_NAME"
echo "Region: $REGION"

# Check if bucket exists
if aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'
then
    echo "📦 Creating new bucket..."
    aws s3 mb s3://$BUCKET_NAME --region $REGION
    
    echo "🔓 Configuring public access..."
    aws s3api put-public-access-block \
        --bucket $BUCKET_NAME \
        --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
    
    echo "📋 Applying bucket policy..."
    sed "s/BUCKET_NAME/$BUCKET_NAME/g" bucket-policy.json > /tmp/bucket-policy-temp.json
    aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file:///tmp/bucket-policy-temp.json
    rm /tmp/bucket-policy-temp.json
    
    echo "🌐 Enabling website hosting..."
    aws s3 website s3://$BUCKET_NAME/ --index-document index.html --error-document error.html
else
    echo "✅ Bucket already exists, updating files..."
fi

echo "📤 Syncing website files..."
aws s3 sync website/ s3://$BUCKET_NAME/ --delete

echo ""
echo "✨ Deployment complete!"
echo "🔗 Your website is available at:"
echo "   http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
echo ""
echo "📊 Bucket contents:"
aws s3 ls s3://$BUCKET_NAME/ --recursive --human-readable