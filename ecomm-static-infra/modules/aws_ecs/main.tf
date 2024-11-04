resource "aws_ecs_cluster" "this" {
  name = "${var.env}-${var.service_name}-cluster"
    setting {
    name  = "containerInsights"
    value = (var.enable_container_insights == true) ? "enabled" : "disabled"
  }
}