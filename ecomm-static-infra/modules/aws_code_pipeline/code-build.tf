resource "aws_codebuild_project" "this" {
  name         = "${var.env}-${var.pipe_line_config.service_name}-codebuild"
  description  = "Codebuild for the ECS Green/Blue ${var.pipe_line_config.service_name} app"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:4.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "CONTAINER_NAME"
      value = "${var.env}-${var.pipe_line_config.service_name}"
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${var.env}-${var.application_name}-${var.pipe_line_config.service_name}"
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.aws_account_id
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }

    environment_variable {
      name  = "SERVICE_PORT"
      value = var.pipe_line_config.container_port
    }

    environment_variable {
      name  = "MEMORY_RESV"
      value = var.pipe_line_config.memory_reserv
    }
    environment_variable {
      name  = "TASK_DEFINITION_FAMILY"
      value = var.task_definition_family
    }
    environment_variable {
      name  = "TASK_DEFINITION_ARN"
      value = var.task_definition_arn
    }
    environment_variable {
      name  = "ECS_ROLE"
      value = var.ecs_role
    }
    environment_variable {
      name  = "ECS_TASK_ROLE"
      value = var.ecs_task_role
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/${local.github_owner}/${local.github_repo}.git"
    git_clone_depth = 1
  }
}