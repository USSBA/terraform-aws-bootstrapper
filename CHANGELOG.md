# Releases

## Terraform v1.9.x

### v3.3.0

* Added bucket policy statement to allow deletion of `.tflock` files for native S3 state locking.

* Added lifecycle configuration to remove expired delete markers, abort incomplete multipart uploads after 7 days, and retain noncurrent versions for 90 days.

### v3.2.0

* Terraform v1.9 is now the minimum required version

### v3.1.0

* Added a new `backup_tags(map)` variable that can be used to set backup tags on the Terraform s3 backend bucket for the AWS Backup Vault service. **These tags must already be configured on the AWS Backup Vault, this module does not supply that functionality**.

## AWS Provider 5.X.X

### v3.0.0

* Module now requires Terraform ~> 1.5 and Provider ~> 5.0

## AWS Provider 4.X.X

### v2.4.0

* Added s3 bucket public access blocking, this is enabled by default. As this bucket should not be public.

### v2.3.0

* Added support for s3 logging.

### v2.2.0

* Added new **tags** variable that can be used to add additional tags to the dynamodb table and s3 bucket.

### v2.1.0

* Added new **string(list)** variable `principals` that can be used to override the default of root
but must line up same number of elements in the `account_ids` list

### v2.0.0

* Support for AWS Provider 4.1

## AWS Provider 3.X.X

### v1.2.0

* Support for Terraform versions 1.0+

### v1.1.0

* Support for Terraform versions 0.13 and above to (but not including) 1.0

### v1.0.0

* Initial release
