resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${aws_lambda_function.user_lambda.function_name}"
  retention_in_days = 14
}
resource "aws_cloudwatch_log_group" "admin_lambda_log_group" {
  name = "/aws/lambda/${aws_lambda_function.admin_lambda.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "api_gateway_log_group" {
  name = "/aws/api_gateway/${aws_apigatewayv2_api.this.name}"
  retention_in_days = 14
}