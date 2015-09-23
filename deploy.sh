#!/bin/bash
set -eu -o pipefail
SHA1=$1
AWS_ENVIRONMENT_NAME=$2

# Prepare the source bundle .zip
EB_BUCKET=champaign.dockerrun.files
echo 'Shipping source bundle to S3...'
#sed "s/<TAG>/$SHA1/" < Dockerrun.aws.json.template > $DOCKERRUN_FILE

DOCKERRUN_FILE=$SHA1-Dockerrun.aws.json
aws configure set default.region $AWS_REGION
aws s3 cp $DOCKERRUN_FILE s3://$EB_BUCKET/$DOCKERRUN_FILE

# Ship to AWS Elastic Beanstalk
echo 'Creating new application version...'
aws elasticbeanstalk create-application-version --application-name "$AWS_APPLICATION_NAME" \
  --version-label $SHA1 --source-bundle S3Bucket=$EB_BUCKET,S3Key=$DOCKERRUN_FILE
echo 'Updating environment...'
aws elasticbeanstalk update-environment --environment-name $AWS_ENVIRONMENT_NAME \
    --version-label $SHA1

