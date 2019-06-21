#!/bin/bash
set -e
set -o pipefail

instruction()
{
  echo "usage: ./build.sh deploy <stage>"
  echo ""
  echo "stage: eg. dev, staging, prod, ..."
  echo ""
  echo "for example: ./deploy.sh dev"
}

if [ $# -eq 0 ]; then
  instruction
  exit 1
elif [ "$1" = "deploy" ] && [ $# -eq 2 ]; then
  STAGE=$2

  npm ci
  zip -r workshop.zip functions static node_modules lib

  MD5=$(md5 -q workshop.zip)
  aws s3 cp workshop.zip s3://ynap-production-ready-serverless-misu/workshop/$MD5.zip
  
  cd terraform
  terraform apply --var "my_name=misu" --var "file_name=$MD5"
else
  instruction
  exit 1
fi