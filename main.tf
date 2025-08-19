data "aws_caller_identity" "current" {}
locals {
  # Note: The bucket will be created if the current account ID matches the 'bucket_source_account_id' variable
  bucket_count = data.aws_caller_identity.current.account_id == var.bucket_source_account_id ? 1 : 0
}

## Bucket
## Note: The bucket need only exist in one account but both accounts must have read/write access to the bucket
## Note: The 'var.bucket_source_account_id' variable which account the bucket will be provisioned
resource "aws_s3_bucket" "bucket" {
  count = local.bucket_count

  bucket = var.bucket_name
  tags = merge(var.tags, var.backup_tags, {
    Name = "Terraform S3 Backend State Store",
  })
}

resource "aws_s3_bucket_public_access_block" "bucket_access" {
  count  = local.bucket_count
  bucket = aws_s3_bucket.bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  count = local.bucket_count - (length(trim(var.log_bucket, " ")) == 0 ? 1 : 0)

  bucket        = aws_s3_bucket.bucket[0].id
  target_bucket = var.log_bucket
  target_prefix = var.log_prefix
}
resource "aws_s3_bucket_versioning" "bucket_version" {
  count = local.bucket_count

  bucket = aws_s3_bucket.bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

## Bucket Lifecycle
## Note: Cleans up expired delete markers, keeps noncurrent versions, and aborts incomplete MPUs
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  count  = local.bucket_count
  bucket = aws_s3_bucket.bucket[0].id

  rule {
    id     = "cleanup-delete-markers-and-retain-versions"
    status = "Enabled"

    # Applies to entire bucket (S3 lifecycle can't filter by suffix)
    filter {}

    expiration {
      expired_object_delete_marker = true
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_retention_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = var.abort_incomplete_mpu_days
    }
  }
}

## Bucket Policy
## Note: The policy will allow S3 read/write actions for each account ID passed to the module
resource "aws_s3_bucket_policy" "bucket_policy" {
  count  = local.bucket_count
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.bucket_policy[0].json
}
data "aws_iam_policy_document" "bucket_policy" {
  count = local.bucket_count
  statement {
    sid = "Object Level Actions"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]
    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:%s", var.account_ids, length(var.principals) == 0 ? [for x in var.account_ids : "root"] : var.principals)
    }
    resources = ["${aws_s3_bucket.bucket[0].arn}/*"]
  }
  statement {
    sid = "Bucket Level Actions"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketVersions",
    ]
    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:%s", var.account_ids, length(var.principals) == 0 ? [for x in var.account_ids : "root"] : var.principals)
    }
    resources = [aws_s3_bucket.bucket[0].arn]
  }

  #Allow deletion of ONLY .tflock files (used by native S3 lockfile)
  statement {
    sid     = "AllowDeleteOnlyTFLock"
    actions = ["s3:DeleteObject"]
    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:%s", var.account_ids, length(var.principals) == 0 ? [for x in var.account_ids : "root"] : var.principals)
    }
    # cover flat keys and one-level prefixes (e.g., workspace/prefix)
    resources = [
      "${aws_s3_bucket.bucket[0].arn}/*.tflock"
    ]
  }
}

## DynamoDB
## Note: Only a single table in each account is necessary, but we support the creation of multiple lock tables
resource "aws_dynamodb_table" "locktable" {
  count        = length(var.lock_table_names)
  name         = var.lock_table_names[count.index]
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(var.tags, {
    Name = "Locktable",
  })
}
