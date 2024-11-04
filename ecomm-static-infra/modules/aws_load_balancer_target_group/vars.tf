variable "env" {
  type = string
}
variable "application_name" {
  type = string
}
variable "region" {
  type = string
}
variable "aws_vpc_id" {
  type = string
}
variable "aws_public_subnet_id" {
  type = list
}
variable "public_security_group_port" {
  type = list
}