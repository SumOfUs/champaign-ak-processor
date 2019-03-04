#!/bin/bash
set -eu -o pipefail

docker docker build -t soutech/champaign-ak-processor:$CIRCLE_SHA1 .

docker login -u $DOCKER_USER -p $DOCKER_PASS
docker push soutech/champaign-ak-processor
