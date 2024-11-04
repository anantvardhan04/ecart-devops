resource "aws_cloudwatch_log_group" "docker" {
  name              = "${var.env}-${var.service_name}-${var.cloudwatch_prefix}/var/log/docker"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "ecs-agent" {
  name              = "${var.env}-${var.service_name}-${var.cloudwatch_prefix}/var/log/ecs/ecs-agent.log"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "ecs-init" {
  name              = "${var.env}-${var.service_name}-${var.cloudwatch_prefix}/var/log/ecs/ecs-init.log"
  retention_in_days = 30
}
