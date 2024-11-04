variable "env" {
  type = string
}
variable "region" {
  type = string
}
variable "application_name" {
  type = string
}
variable "access_key" {
  type = string
}
variable "secret_key" {
  type = string
}
variable "aws_account_id" {
  type = string
}
variable "public_file_name" {
  type = string
}
variable "public_security_group_port" {
  type = list(number)
}