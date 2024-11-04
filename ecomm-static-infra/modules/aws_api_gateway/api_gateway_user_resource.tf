data "archive_file" "api_user" {
  type        = "zip"
  output_path = "user.zip"
  source_dir  = "./lambda/user_greet"
}

resource "aws_lambda_function" "user_lambda" {
  filename      = "user.zip"
  function_name = "user_lambda"
  role          = aws_iam_role.api_gateway_lambda_role.arn
  handler       = "handler.user"
  runtime       = "python3.7"

  source_code_hash = data.archive_file.api_user.output_base64sha256
}


resource "aws_apigatewayv2_integration" "user_lambda" {
  api_id = aws_apigatewayv2_api.this.id

  integration_uri    = aws_lambda_function.user_lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "get_hello" {
  api_id = aws_apigatewayv2_api.this.id

  route_key = "GET /user"
  target    = "integrations/${aws_apigatewayv2_integration.user_lambda.id}"
}


resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}
