# Terraform Variables
variable "aws_region" {
  description = "AWS Deployment Region"
  default     = "${env.AWS_REGION}"
}

variable "s3_bucket_name" {
  description = "S3 Bucket for Terraform State"
  default     = "${env.S3_BUCKET_NAME}"
}

variable "dynamodb_table_name" {
  description = "DynamoDB Table for Terraform State Lock"
  default     = "${env.DYNAMODB_TABLE_NAME}"
}