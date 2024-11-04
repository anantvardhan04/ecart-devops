locals {
  github_owner  = var.pipe_line_config.github_owner
  github_repo   = var.pipe_line_config.github_repo
  github_branch = var.pipe_line_config.github_branch
}

resource "aws_codepipeline" "this" {
  name     = "${var.env}-${var.pipe_line_config.service_name}-pipeline"
  role_arn = aws_iam_role.pipeline.arn

  artifact_store {
    location = "${var.env}-${var.pipe_line_config.service_name}-codepipeline-bucket"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      configuration = {
        ConnectionArn    = "arn:aws:codestar-connections:ap-south-1:975050162729:connection/bc896329-0416-46cf-a71f-10e6f1cc9c9e"
        FullRepositoryId = "${local.github_owner}/${local.github_repo}"
        BranchName       = "${local.github_branch}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = "${aws_codebuild_project.this.name}"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "ExternalDeploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["BuildArtifact"]
      version         = "1"

      configuration = {
        ApplicationName                = "${var.pipe_line_config.service_name}-service-deploy"
        DeploymentGroupName            = "${var.pipe_line_config.service_name}-service-deploy-group"
        TaskDefinitionTemplateArtifact = "BuildArtifact"
        TaskDefinitionTemplatePath     = "taskdef.json"
        AppSpecTemplateArtifact        = "BuildArtifact"
        AppSpecTemplatePath            = "appspec.yaml"
      }
    }
  }
}
