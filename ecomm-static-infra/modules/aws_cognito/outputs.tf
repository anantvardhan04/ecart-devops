output "user_pool" {
  value = aws_cognito_user_pool.this
}
output "user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.this.id
}
output "user_pool_client" {
  value = aws_cognito_user_pool_client.this
}

