resource "aws_cognito_user_pool" "this" {
  name = var.cognito_user_pool_name
  username_attributes = ["email"]
  admin_create_user_config {
    allow_admin_create_user_only = false
  }
  mfa_configuration = "OFF"

//  software_token_mfa_configuration {
//    enabled = true
//  }
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

  }
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length = 10
    require_lowercase = true
    require_numbers = true
    require_symbols = true
    require_uppercase = true
  }
}

resource "aws_cognito_user_pool_client" "this" {
  allowed_oauth_flows = [
    "implicit"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = [
    "openid"]
  callback_urls = var.cognito_user_pool_callback_urls
  name = var.cognito_user_pool_client_name
  supported_identity_providers = [
    "COGNITO"]
  //  supported_identity_providers         = [aws_cognito_identity_provider.this.provider_name]
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_user_pool_domain" "main" {
  domain = var.domain_name
  user_pool_id = aws_cognito_user_pool.this.id
  //  certificate_arn = local.certificate_arn
}
# creating user group into cognito
resource "aws_cognito_user_group" "main" {
  name         = "user"
  user_pool_id = aws_cognito_user_pool.this.id
  description  = "Managed by Terraform"
  precedence   = 43
  role_arn     = aws_iam_role.group_role.arn
}
resource "aws_cognito_user_group" "admin_main" {
  name         = "admin"
  user_pool_id = aws_cognito_user_pool.this.id
  description  = "Managed by Terraform"
  precedence   = 42
  role_arn     = aws_iam_role.admin_group_role.arn
}
