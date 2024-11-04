resource "aws_codebuild_project" "this" {
  name         = "${var.env}-${var.pipe_line_config.service_name}-codebuild"
  description  = "Codebuild for ${var.pipe_line_config.service_name}"
  service_role = "${aws_iam_role.codebuild.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${var.env}-${var.pipe_line_config.service_name}"
    }
    environment_variable {
      name  = "S3_BUCKET"
      value = "${var.env}-${var.pipe_line_config.s3_bucket}"
    }
    environment_variable {
      name  = "DISTRIBUTION_ID"
      value = "${var.cloud_front_distribution_id}"
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "${var.aws_account_id}"
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "${var.region}"
    }
    environment_variable {
      name  = "apiBaseUrl"
      value = "${var.apiBaseUrl}"
    }
     environment_variable {
      name  = "userPoolId"
      value = "${var.userPoolId}"
    }
     environment_variable {
      name  = "userPoolWebClientId"
      value = "${var.userPoolWebClientId}"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/${local.github_owner}/${local.github_repo}.git"
    git_clone_depth = 1
  }
}

//resource "aws_codebuild_webhook" "example" {
//  project_name = aws_codebuild_project.this.name
//  build_type   = "BUILD"
//  filter_group {
//    filter {
//      type    = "EVENT"
//      pattern = "PUSH"
//    }
//  }
//}