provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = var.s3_bucket_name  
    key            = "terraform/state.tfstate"  
    region         = var.aws_region
    dynamodb_table = var.dynamodb_table_name  
    encrypt        = true 
  }
}


resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}


