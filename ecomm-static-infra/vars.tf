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
//variable "service_name" {
//  type = string
//}
//variable "container_port" {
//  type = string
//}
//variable "memory_reserv" {
//  type = string
//}

//variable "github_branch" {
//  type = string
//}
//variable "github_repo" {
//  type = string
//}
//variable "github_owner" {
//  type = string
//}
//variable "github_token" {
//  type = string
//}
