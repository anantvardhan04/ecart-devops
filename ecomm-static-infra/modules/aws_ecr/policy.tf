data "aws_iam_policy_document" "assume_by_ecr" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecr" {
  name               = "${var.service_name}-ECR-ReadForECSServiceAccount"
  assume_role_policy = "${data.aws_iam_policy_document.assume_by_ecr.json}"
}

data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid    = "DescribeImages"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.ecr.arn}"]
    }

    actions = [
      "ecr:*"
    ]
  }
}

resource "aws_ecr_repository_policy" "this" {
  repository = "${var.env}-${var.application_name}-${var.service_name}"
  policy     = "${data.aws_iam_policy_document.ecr_policy.json}"
}
