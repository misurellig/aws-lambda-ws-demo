terraform {
  backend "s3" {
    bucket="ynap-production-ready-serverless-misu"
    key="terraform.tfstate"
    region="us-east-1"
  }
}