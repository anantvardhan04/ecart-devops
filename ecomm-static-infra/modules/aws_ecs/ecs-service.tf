resource "aws_ecs_service" "this" {
  name            = "${var.env}-${var.application_name}-${var.service_name}"
  task_definition = aws_ecs_task_definition.this.id
  cluster         = aws_ecs_cluster.this.arn

  load_balancer {
    target_group_arn = var.target_group_arn[0]
    container_name   = "${var.env}-${var.service_name}"
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = ["task_definition", "load_balancer"]
  }
  network_configuration {
    security_groups  = ["${aws_security_group.ecs.id}"]
    subnets          = var.public_subnet_ids
    assign_public_ip = true
  }

  launch_type          = "FARGATE"
  desired_count        = 1
  force_new_deployment = true

  deployment_controller {
    type = "CODE_DEPLOY"
  }
}
