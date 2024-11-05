locals {
  tags = merge(
    var.tags,
  )
}

resource "aws_s3_bucket" "website_bucket" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = local.tags
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

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_cloudfront_distribution" "website_cdn" {
  enabled         = true
  is_ipv6_enabled = var.ipv6
  price_class     = var.price_class
  http_version    = "http2"

  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.website_bucket.id}"
    domain_name = aws_s3_bucket_website_configuration.example.website_endpoint

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1"]
    }

    custom_header {
      name  = "User-Agent"
      value = var.duplicate-content-penalty-secret
    }
  }

  default_root_object = var.default-root-object

  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = "5"
    response_code         = var.not-found-response-code
    response_page_path    = var.not-found-response-path
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "DELETE", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = var.forward-query-string

      cookies {
        forward = "none"
      }
    }

    trusted_signers = var.trusted_signers

    min_ttl          = "0"
    default_ttl      = "5" //3600
    max_ttl          = "5" //86400
    target_origin_id = "origin-bucket-${aws_s3_bucket.website_bucket.id}"

    // This redirects any HTTP request to HTTPS. Security first!
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = var.minimum_client_tls_protocol_version
  }

  tags = local.tags
}
