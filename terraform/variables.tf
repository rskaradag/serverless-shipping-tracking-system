# Terraform Variables
variable "aws_region" {
  description = "AWS Deployment Region"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 Bucket for Terraform State"
   type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB Table for Terraform State Lock"
   type        = string
}