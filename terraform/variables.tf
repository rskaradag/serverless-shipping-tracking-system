# Terraform Variables
variable "aws_region" {
  description = "AWS Deployment Region"
  type        = string
}
variable "stage_name" {
  default = "dev"
  type    = string
}
variable "dynamodb_table_name" {}
variable "s3_bucket_name" {}
variable "sqs_queue_name" {}