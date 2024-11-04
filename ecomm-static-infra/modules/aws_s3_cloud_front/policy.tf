data "template_file" "bucket_policy" {
  template = file("${path.module}/website_bucket_policy.json")
  vars = {
    bucket = aws_s3_bucket.website_bucket.arn
    secret = var.duplicate-content-penalty-secret
    cf     = aws_cloudfront_distribution.website_cdn.arn
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_cloud_front" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.template_file.bucket_policy.rendered
}

data "template_file" "deployer_role_policy_file" {
  template = file("${path.module}/deployer_role_policy.json")
  vars = {
    bucket = aws_s3_bucket.website_bucket.arn
  }
}

resource "aws_iam_policy" "site_deployer_policy" {
  count       = var.deployer != null ? 1 : 0
  name        = "${var.bucket_name}.deployer"
  path        = "/"
  description = "Policy allowing to publish a new version of the website to the S3 bucket"
  policy      = data.template_file.deployer_role_policy_file.rendered
}

resource "aws_iam_policy_attachment" "site-deployer-attach-user-policy" {
  count      = var.deployer != null ? 1 : 0
  name       = "${var.bucket_name}-deployer-policy-attachment"
  users      = [var.deployer]
  policy_arn = aws_iam_policy.site_deployer_policy.0.arn
}