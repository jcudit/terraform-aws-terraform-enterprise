resource "aws_s3_bucket" "license" {
  region = var.region
  acl    = "private"

  force_destroy = true

  versioning {
    enabled = true
  }

  tags = {
    Name = "${var.environment}-s3-bucket"
  }
}

resource "aws_s3_bucket_object" "license" {
  bucket = aws_s3_bucket.license.id
  key    = "license.rli"
  source = "${path.module}/tfe-trial-license.rli"

  etag = filemd5("${path.module}/tfe-trial-license.rli")
}
