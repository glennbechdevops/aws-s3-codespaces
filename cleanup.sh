#!/bin/bash
# Usage: ./cleanup.sh bucket-name

if [ -z "$1" ]; then
    echo "Usage: ./cleanup.sh bucket-name"
    exit 1
fi

BUCKET_NAME=$1

aws s3 rm s3://$BUCKET_NAME --recursive
aws s3 rb s3://$BUCKET_NAME
