resource "aws_ecr_repository" "this" {
  name  = "${var.env}-${var.application_name}-${var.service_name}"
}