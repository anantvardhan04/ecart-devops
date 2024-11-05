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
        ConnectionArn    = "arn:aws:codeconnections:ap-south-1:149536485745:connection/0690d008-c439-425c-8601-58e0a2061d0e"
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
}
