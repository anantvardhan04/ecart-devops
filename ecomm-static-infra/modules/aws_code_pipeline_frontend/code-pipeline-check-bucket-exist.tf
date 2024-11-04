data "aws_partition" "current" {

}
data "aws_caller_identity" "current" {}

locals {
  bucket_id             = "${var.env}-${var.pipe_line_config.service_name}-codepipeline-bucket"
  enable_bucket_logging = var.logging_bucket != ""
}

data "aws_iam_policy_document" "supplemental_policy" {
  # This should be a single line:
  # source_policy_documents = [var.custom_bucket_policy]
  #
  # However, there appears to be a bug that occurs when source_policy_documents is an empty string:
  # - https://github.com/hashicorp/terraform-provider-aws/issues/22959
  # - https://github.com/hashicorp/terraform-provider-aws/issues/24366
  #
  # To work around this, we're using this workaround. It should be replaced
  # once the underlying issue is addressed.
  source_policy_documents = length(var.custom_bucket_policy) > 0 ? [var.custom_bucket_policy] : null

  # Enforce SSL/TLS on all transmitted objects
  # We do this by extending the custom_bucket_policy
  statement {
    sid = "enforce-tls-requests-only"

    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${local.bucket_id}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid = "inventory-and-analytics"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${local.bucket_id}/*"
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:s3:::${local.bucket_id}"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.aws_account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket" "private_bucket" {
  bucket        = var.use_random_suffix ? null : local.bucket_id
  tags          = var.tags
  force_destroy = var.enable_bucket_force_destroy

  lifecycle {
    # These lifecycle ignore_changes rules exist to permit a smooth upgrade
    # path from version 3.x of the AWS provider to version 4.x
    ignore_changes = [
      # While no special usage instructions are documented for needing this
      # ignore_changes rule, changes are still detected during the upgrade
      # process, so this serves to avoid drift detection since the
      # aws_s3_bucket_policy will be used instead.
      policy,

      # While no special usage instructions are documented for needing this
      # ignore_changes rule, this should avoid drift detection if conflicts
      # with the aws_s3_bucket_versioning exist.
      versioning,

      # https://registry.terraform.io/providers/hashicorp%20%20/aws/3.75.2/docs/resources/s3_bucket_acl#usage-notes
      acceleration_status,
      acl,
      grant,

      # https://registry.terraform.io/providers/hashicorp%20%20/aws/3.75.2/docs/resources/s3_bucket_cors_configuration#usage-notes
      cors_rule,

      # https://registry.terraform.io/providers/hashicorp%20%20/aws/3.75.2/docs/resources/s3_bucket_lifecycle_configuration#usage-notes
      lifecycle_rule,

      # https://registry.terraform.io/providers/hashicorp%20%20/aws/3.75.2/docs/resources/s3_bucket_logging#usage-notes
      logging,

      # https://registry.terraform.io/providers/hashicorp%20%20/aws/3.75.2/docs/resources/s3_bucket_server_side_encryption_configuration#usage-notes
      server_side_encryption_configuration,
    ]
  }
}

resource "aws_s3_bucket_policy" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id
  policy = data.aws_iam_policy_document.supplemental_policy.json
}

resource "aws_s3_bucket_accelerate_configuration" "private_bucket" {
  count = var.transfer_acceleration != null ? 1 : 0

  bucket = aws_s3_bucket.private_bucket.id
  status = var.transfer_acceleration ? "Enabled" : "Suspended"
}

# resource "aws_s3_bucket_acl" "private_bucket" {
#   bucket = aws_s3_bucket.private_bucket.id
#   acl    = "private"
# }

resource "aws_s3_bucket_versioning" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id

  versioning_configuration {
    status = var.versioning_status
  }
}
resource "aws_s3_bucket_cors_configuration" "private_bucket" {
  count = length(var.cors_rules)

  bucket = aws_s3_bucket.private_bucket.bucket

  cors_rule {
    allowed_methods = var.cors_rules[count.index].allowed_methods
    allowed_origins = var.cors_rules[count.index].allowed_origins
    allowed_headers = lookup(var.cors_rules[count.index], "allowed_headers", null)
    expose_headers  = lookup(var.cors_rules[count.index], "expose_headers", null)
    max_age_seconds = lookup(var.cors_rules[count.index], "max_age_seconds", null)
  }
}
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  count = var.enable_s3_public_access_block ? 1 : 0

  bucket = aws_s3_bucket.private_bucket.id

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}