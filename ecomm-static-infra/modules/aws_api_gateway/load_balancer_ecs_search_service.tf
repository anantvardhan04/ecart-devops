resource "aws_apigatewayv2_integration" "search_service_intergration" {
  api_id           = aws_apigatewayv2_api.this.id
  description      = "Example with a load balancer"
  integration_type = "HTTP_PROXY"
  integration_uri  = "http://${var.load_balancer_uri}"

  integration_method = "ANY"

  request_parameters = {
    "overwrite:path" = "$request.path"
  }
}

resource "aws_apigatewayv2_route" "search_service" {
  api_id = aws_apigatewayv2_api.this.id

  route_key = "ANY /product/{product+}"
  target    = "integrations/${aws_apigatewayv2_integration.search_service_intergration.id}"
}
