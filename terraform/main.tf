provider "aws" {
  region = var.aws_region
}

data "aws_s3_bucket" "terraform_state" {
  bucket = "tf-serverless-shipping-tracking-system"
}

data "aws_dynamodb_table" "app-state" {
  name = "app-state"
}

terraform {
  backend "s3" {
    bucket         = "tf-serverless-shipping-tracking-system"
    key            = "terraform/state.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "app-state"
    encrypt        = true
  }
}