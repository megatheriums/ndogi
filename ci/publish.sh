#!/usr/bin/env bash

echo "Publishing to $REPOSITORY_URL"
REPOSITORY_PASSWORD=`aws ecr get-login-password --region $AWS_REGION`
docker login --username AWS --password $REPOSITORY_PASSWORD $REPOSITORY_URL
# docker build -t $IMAGE_NAME .
# docker tag $IMAGE_NAME:latest $REPOSITORY_URL:latest
docker push $REPOSITORY_URL:latest
