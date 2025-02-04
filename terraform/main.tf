provider "aws" {
  region = var.aws_region
}

data "aws_s3_bucket" "terraform_state" {
  bucket = "tf-serverless-shipping-tracking-system"
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "Production"
  }
}

terraform {
  backend "s3" {
    bucket         = "tf-serverless-shipping-tracking-system"
    key            = "terraform/state.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}