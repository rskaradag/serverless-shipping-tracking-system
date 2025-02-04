provider "aws" {
  region = var.aws_region
}

data "aws_s3_bucket" "terraform_state" {
  bucket = "tfstate"
}

data "aws_dynamodb_table" "app-state" {
  name = "app-state"
}

terraform {
  backend "s3" {
    bucket         = data.aws_s3_bucket.terraform_state.bucket
    key            = "terraform/state.tfstate"
    region         = var.aws_region
    dynamodb_table = data.aws_dynamodb_table.app-state.name
    encrypt        = true
  }
}