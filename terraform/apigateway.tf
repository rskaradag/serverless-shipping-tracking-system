resource "aws_api_gateway_rest_api" "shipping_api" {
  name        = "ShippingTrackingAPI"
  description = "API Gateway for shipping tracking system"
}

resource "aws_api_gateway_resource" "tracking" {
  rest_api_id = aws_api_gateway_rest_api.shipping_api.id
  parent_id   = aws_api_gateway_rest_api.shipping_api.root_resource_id
  path_part   = "tracking"
}

resource "aws_api_gateway_method" "tracking_post" {
  rest_api_id   = aws_api_gateway_rest_api.shipping_api.id
  resource_id   = aws_api_gateway_resource.tracking.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.shipping_api.id
  resource_id = aws_api_gateway_resource.tracking.id
  http_method = aws_api_gateway_method.tracking_post.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.create_tracking.invoke_arn
}

resource "aws_api_gateway_deployment" "tracking_api_deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.shipping_api.id
  stage_name  = "prod"
}

resource "aws_lambda_function" "create_tracking" {
  filename      = "create_tracking_lambda.zip"
  function_name = "createTrackingHandler"
  role          = data.aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.9"
}

data "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"
}
