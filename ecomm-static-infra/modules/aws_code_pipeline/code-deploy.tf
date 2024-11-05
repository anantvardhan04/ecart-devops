resource "aws_codedeploy_app" "this" {
  compute_platform = "ECS"
  name             = "${var.pipe_line_config.service_name}-service-deploy"
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_group_name  = "${var.pipe_line_config.service_name}-service-deploy-group"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = aws_iam_role.codedeploy.arn

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  ecs_service {
    cluster_name = "${var.env}-${var.pipe_line_config.service_name}-cluster"
    service_name = "${var.env}-${var.application_name}-${var.pipe_line_config.service_name}"
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = ["${var.load_balancer_listener_arn}"]
      }

      target_group {
        name = var.target_group_info[0]
      }

      target_group {
        name = var.target_group_info[1]
      }
    }
  }
  trigger_configuration {
    trigger_events = [
      "DeploymentSuccess",
      "DeploymentFailure",
    ]

    trigger_name       = var.trigger_name
    trigger_target_arn = var.sns_topic_arn
  }
}
