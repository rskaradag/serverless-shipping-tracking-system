resource "aws_lambda_function" "create_tracking" {
  filename      = "create_tracking_lambda.zip"
  function_name = "createTrackingHandler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "create_tracking.handler"
  runtime       = "python3.9"
  source_code_hash = data.archive_file.zip_the_python_code_create_tracking.output_base64sha256

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.order_queue.url
    }
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_tracking.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "allow_sqs_invoke_lambda" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.consumer.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.order_queue.arn
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role_serverless"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Define IAM policy for Lambda to send messages to SQS and write logs
resource "aws_iam_policy" "lambda_policy" {
  name        = "LambdaPolicy-Serverless"
  description = "Grants Lambda permissions to send messages to SQS"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.order_queue.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.tracking_updates.arn
      }
    ]
  })
}

# Attach the IAM policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_attach_policy" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

data "archive_file" "zip_the_python_code_create_tracking" {
  type        = "zip"
  source_file = "../lambda/create_tracking/create_tracking.py"
  output_path = "${path.module}/create_tracking_lambda.zip"
}

data "archive_file" "zip_the_python_code_consumer" {
  type        = "zip"
  source_file = "../lambda/consumer/consumer.py"
  output_path = "${path.module}/consumer.zip"
}


resource "aws_lambda_function" "consumer" {
  filename      = "consumer.zip"
  function_name = "consumerHandler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "consumer.handler"
  runtime       = "python3.9"
  source_code_hash = data.archive_file.zip_the_python_code_consumer.output_base64sha256

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.order_queue.url
      SNS_TOPIC_ARN = aws_sns_topic.tracking_updates.arn
    }
  }
}

resource "aws_lambda_event_source_mapping" "consumer" {
  event_source_arn = aws_sqs_queue.order_queue.arn
  function_name    = aws_lambda_function.consumer.arn
}
