data "archive_file" "api_admin" {
  type        = "zip"
  output_path = "admin.zip"
  source_dir  = "./lambda/admin_greet"
}

resource "aws_lambda_function" "admin_lambda" {
  filename      = "admin.zip"
  function_name = "admin_lambda"
  role          = aws_iam_role.api_gateway_lambda_role.arn
  handler       = "handler.admin"
  runtime       = "python3.8"

  source_code_hash = data.archive_file.api_user.output_base64sha256
}

resource "aws_apigatewayv2_integration" "admin_lambda" {
  api_id = aws_apigatewayv2_api.this.id

  integration_uri    = aws_lambda_function.admin_lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "get_admin_hello" {
  api_id = aws_apigatewayv2_api.this.id

  route_key = "GET /admin"
  target    = "integrations/${aws_apigatewayv2_integration.admin_lambda.id}"
}


# resource "aws_lambda_permission" "api_admin_lambda_gw" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.admin_lambda.function_name
#   principal     = "apigateway.amazonaws.com"

#   source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
# }
