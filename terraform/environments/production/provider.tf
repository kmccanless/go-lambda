provider "aws" {
  region = var.region
  profile= var.profile
}
#TODO this needs to match the production state in infrastructure
terraform {
  backend "s3" {
    bucket         = "go-lambda-terraform-state"
    key            = "production/function/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "production-go-lambda-terraform-locks"
    encrypt        = true
    profile        = "keith"
  }
}