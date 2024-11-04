# This file is used to create the API Gateway and its stage.
locals {
  resource_name_prefix = "${var.env}-${var.resource_tag_name}"
  api_url              = aws_apigatewayv2_api.this.api_endpoint
  api_name             = "${local.resource_name_prefix}-${var.application_name}"
}

resource "aws_apigatewayv2_api" "this" {
  name          = local.api_name
  protocol_type = "HTTP"
  dynamic "cors_configuration" {
    for_each = length(keys(var.cors_configuration)) == 0 ? [] : [var.cors_configuration]

    content {
      allow_credentials = try(cors_configuration.value.allow_credentials, null)
      allow_headers     = try(cors_configuration.value.allow_headers, null)
      allow_methods     = try(cors_configuration.value.allow_methods, null)
      allow_origins     = try(cors_configuration.value.allow_origins, null)
      expose_headers    = try(cors_configuration.value.expose_headers, null)
      max_age           = try(cors_configuration.value.max_age, null)
    }
  }
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id = aws_apigatewayv2_api.this.id

  name        = var.env
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_log_group.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}