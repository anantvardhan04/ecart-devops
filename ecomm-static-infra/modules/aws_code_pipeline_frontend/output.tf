output "id" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.private_bucket.id
}

output "code_pipeline_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = aws_codepipeline.this.arn
}

output "name" {
  description = "The Name of the bucket. Will be of format bucketprefix-bucketname."
  value       = "${var.env}-${var.pipe_line_config.service_name}-codepipeline-bucket"
}

output "bucket_domain_name" {
  description = "The bucket domain name."
  value       = aws_s3_bucket.private_bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name."
  value       = aws_s3_bucket.private_bucket.bucket_regional_domain_name
}