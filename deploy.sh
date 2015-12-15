#!/bin/bash
set -eu -o pipefail
SHA1=$1
AWS_APPLICATION_NAME=$2
AWS_ENVIRONMENT_NAME=$3

# Set configuration for logging with Papertrail
export PAPERTRAIL_HOST=$(cut -d ":" -f 1 <<< $4)
export PAPERTRAIL_PORT=$(cut -d ":" -f 2 <<< $4)

# Set the right place for paper trail logging
cat .ebextensions/02_papertrail.config | envsubst "$PAPERTRAIL_HOST:$PAPERTRAIL_PORT" >tmp
mv tmp .ebextensions/02_papertrail.config

# Prepare the source bundle .zip
EB_BUCKET=champaign.dockerrun.files
echo 'Shipping source bundle to S3...'
zip -r9 $SHA1-config.zip Dockerrun.aws.json ./.ebextensions/
SOURCE_BUNDLE=$SHA1-config.zip

aws configure set default.region $AWS_REGION
aws s3 cp $SOURCE_BUNDLE s3://$EB_BUCKET/$SOURCE_BUNDLE

# Ship to AWS Elastic Beanstalk
echo 'Creating new application version...'
aws elasticbeanstalk create-application-version --application-name "$AWS_APPLICATION_NAME" \
  --version-label $SHA1 --source-bundle S3Bucket=$EB_BUCKET,S3Key=$SOURCE_BUNDLE
echo 'Updating environment...'
aws elasticbeanstalk update-environment --environment-name $AWS_ENVIRONMENT_NAME \
    --version-label $SHA1
