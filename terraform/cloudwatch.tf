resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name              = "/aws/api-gateway/ShippingTrackingAPI"
  retention_in_days = 7
}