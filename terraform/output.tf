
output "queue_URL" {
  value = aws_sqs_queue.order_queue.id
}
output "test_cURL" {
  value = "curl -X POST -H 'Content-Type: application/json' -d '{\"username\":\"selcuk\", \"email\":\"r.selcukkaradag@gmail.com\", \"order_number\":\"6161\"}' ${aws_api_gateway_stage.shipping_api.invoke_url}/order"
}
output "apigateway_url" {
  value = aws_api_gateway_stage.shipping_api.invoke_url
}
