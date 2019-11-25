terraform {
  required_version = "~> 0.12.10"
  required_providers {
    aws = "~> 2.20"
  }
}
data "aws_caller_identity" "current" {}
locals {
  # Only creates bucket when current account is where the bucket lives
  bucket_count = data.aws_caller_identity.current.account_id == var.bucket_source_account_id ? 1 : 0
}

## S3 bucket config
resource "aws_s3_bucket" "bucket" {
  count  = local.bucket_count
  bucket = var.bucket_name
  versioning {
    enabled = true
  }
  tags = {
    Name = "Terraform S3 Backend State Store"
  }
}
data "aws_iam_policy_document" "bucket_policy" {
  count = local.bucket_count
  statement {
    sid = "Object Level Actions"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", var.account_ids)
    }
    resources = ["${aws_s3_bucket.bucket[0].arn}/*"]
  }
  statement {
    sid = "Bucket Level Actions"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketVersions"
    ]
    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", var.account_ids)
    }
    resources = ["${aws_s3_bucket.bucket[0].arn}"]
  }
}
resource "aws_s3_bucket_policy" "bucket_policy" {
  count  = local.bucket_count
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.bucket_policy[0].json
}

## DynamoDB config
resource "aws_dynamodb_table" "locktable" {
  count        = length(var.lock_table_names)
  name         = var.lock_table_names[count.index]
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Locktable"
  }
}
