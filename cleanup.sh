#!/bin/bash

# Cleanup script for S3 bucket
# Usage: ./cleanup.sh bucket-name

if [ -z "$1" ]; then
    echo "❌ Error: Please provide bucket name"
    echo "Usage: ./cleanup.sh bucket-name"
    exit 1
fi

BUCKET_NAME=$1

echo "🗑️ Cleaning up S3 bucket: $BUCKET_NAME"

# Empty the bucket
echo "Removing all objects..."
aws s3 rm s3://$BUCKET_NAME --recursive

# Delete the bucket
echo "Deleting bucket..."
aws s3 rb s3://$BUCKET_NAME

echo "✅ Cleanup complete!"