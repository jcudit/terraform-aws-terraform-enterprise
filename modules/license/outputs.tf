output "license_s3_bucket_id" {
  description = "The bucket the application license is stored in"
  value       = aws_s3_bucket.license.id
}
