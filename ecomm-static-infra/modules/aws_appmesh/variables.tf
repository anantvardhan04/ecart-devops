variable "env" {
  type = string
}
variable "application_name" {
  type = string
}
variable "region" {
  type = string
}

variable "cluster_name" {}

variable "service_name" {}

variable "service_protocol" { default = "http" }

variable "service_healthcheck" {
  type        = map
  default = {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 10
    interval            = 60
    matcher             = "200"
    path                = "/healthcheck"
    port                = 8005
  }
}
variable "container_port" {}