# Define the AWS SQS queue to store order messages
resource "aws_sqs_queue" "order_queue" {
  name = var.sqs_queue_name
  fifo_queue                  = true
  content_based_deduplication = true

  tags = {
    Environment = "production"
  }
}