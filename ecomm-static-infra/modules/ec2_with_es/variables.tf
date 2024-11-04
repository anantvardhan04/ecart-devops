variable "env" {
  type = string
}
variable "region" {
  type = string
}
variable "application_name" {
  type = string
}
variable "service_name" {
  type = string
}

variable "availability_zones" {}
variable "vpc_id" {}
variable "private_subnet_ids" {}

variable "key_name" {}

variable "instance_ami" {
//  default = "ami-03f6a11788f8e319e"
//  default = "ami-0e07dcaca348a0e68"
  default = "ami-0f8ca728008ff5af4"




}
variable "instance_type" { default = "t2.medium" }
variable "instance_count" { default = 1 }

