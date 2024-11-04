//resource "aws_s3_bucket" "s3_bucket" {
//  bucket = "${var.s3_bucket_name}"
//  force_destroy = var.force_destroy
//  lifecycle {
//    # These lifecycle ignore_changes rules exist to permit a smooth upgrade
//    # path from version 3.x of the AWS provider to version 4.x
//    ignore_changes = [
//      # While no special usage instructions are documented for needing this
//      # ignore_changes rule, changes are still detected during the upgrade
//      # process, so this serves to avoid drift detection since the
//      # aws_s3_bucket_policy will be used instead.
//      policy,
//
//      # While no special usage instructions are documented for needing this
//      # ignore_changes rule, this should avoid drift detection if conflicts
//      # with the aws_s3_bucket_versioning exist.
//      versioning,
//
//      # https://registry.terraform.io/providers/hashicorp%20%20/aws/3.75.2/docs/resources/s3_bucket_acl#usage-notes
//      acceleration_status,
//      acl,
//      grant,
//
//      # https://registry.terraform.io/providers/hashicorp%20%20/aws/3.75.2/docs/resources/s3_bucket_cors_configuration#usage-notes
//      cors_rule,
//
//      # https://registry.terraform.io/providers/hashicorp%20%20/aws/3.75.2/docs/resources/s3_bucket_lifecycle_configuration#usage-notes
//      lifecycle_rule,
//
//      # https://registry.terraform.io/providers/hashicorp%20%20/aws/3.75.2/docs/resources/s3_bucket_logging#usage-notes
//      logging,
//
//      # https://registry.terraform.io/providers/hashicorp%20%20/aws/3.75.2/docs/resources/s3_bucket_server_side_encryption_configuration#usage-notes
//      server_side_encryption_configuration,
//    ]
//  }
//}
