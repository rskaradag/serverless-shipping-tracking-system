# Terraform Variables
variable "aws_region" {
  description = "AWS Deployment Region"
  type        = string
}
variable "dynamodb_table_name" {}
variable "s3_bucket_name" {}
