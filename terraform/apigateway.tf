resource "aws_api_gateway_rest_api" "shipping_api" {
  name        = "ShippingTrackingAPI"
  description = "API Gateway for shipping tracking system"
}

resource "aws_api_gateway_request_validator" "shipping_api" {
  rest_api_id           = aws_api_gateway_rest_api.shipping_api.id
  name                  = "payload-validator"
  validate_request_body = true
}

resource "aws_api_gateway_model" "shipping_api" {
  rest_api_id  = aws_api_gateway_rest_api.shipping_api.id
  name         = "PayloadValidator"
  description  = "validate the json body content conforms to the below spec"
  content_type = "application/json"

  schema = <<EOF
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "object",
  "properties": {
    "email": { "type": "string" }
    }
}
EOF
}

resource "aws_api_gateway_resource" "tracking" {
  rest_api_id = aws_api_gateway_rest_api.shipping_api.id
  parent_id   = aws_api_gateway_rest_api.shipping_api.root_resource_id
  path_part   = "order"
}

resource "aws_api_gateway_method" "tracking_post" {
  rest_api_id   = aws_api_gateway_rest_api.shipping_api.id
  resource_id   = aws_api_gateway_resource.tracking.id
  api_key_required     = false
  http_method          = "POST"
  authorization        = "NONE"
  request_validator_id = aws_api_gateway_request_validator.shipping_api.id

}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.shipping_api.id
  resource_id = aws_api_gateway_resource.tracking.id
  http_method = aws_api_gateway_method.tracking_post.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.create_tracking.invoke_arn
  credentials             = aws_iam_role.api.arn

  # request_parameters = {
  #   "integration.request.header.Content-Type" = "application/json"
  # }

  # request_templates = {
  #   "application/json" = "Action=SendMessage&MessageBody=$input.body"
  # }

}

resource "aws_api_gateway_deployment" "tracking_api_deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.shipping_api.id

}

resource "aws_api_gateway_stage" "shipping_api" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.shipping_api.id
  deployment_id = aws_api_gateway_deployment.tracking_api_deployment.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_logs.arn
    format = jsonencode({
      requestId   = "$context.requestId"
      ip          = "$context.identity.sourceIp"
      requestTime = "$context.requestTime"
      httpMethod  = "$context.httpMethod"
      path        = "$context.resourcePath"
      status      = "$context.status"
      responseLatency = "$context.responseLatency"
    })
  }
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.shipping_api.id
  stage_name  = "dev"
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"
  }
}