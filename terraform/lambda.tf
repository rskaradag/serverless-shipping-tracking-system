resource "aws_lambda_function" "create_tracking" {
  filename      = "create_tracking_lambda.zip"
  function_name = "createTrackingHandler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "create_tracking.handler"
  runtime       = "python3.9"
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256

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

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_sqs_role_serverless"

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
resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "LambdaSQSPolicy"
  description = "Grants Lambda permissions to send messages to SQS"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
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
      }
    ]
  })
}

# Attach the IAM policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_attach" {
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
  role       = aws_iam_role.lambda_role.name
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_file = "../lambda/create_tracking/create_tracking.py"
  output_path = "${path.module}/create_tracking_lambda.zip"
}