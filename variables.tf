variable "bucket_name" {
  type        = string
  description = "Required; The bucket name in which terraform state files will be stored."
}
variable "bucket_source_account_id" {
  type        = string
  description = "Required; The account in which the bucket will be created."
}
variable "account_ids" {
  type        = list(string)
  description = "Required; The account IDs that will need access to the bucket."
}
variable "lock_table_names" {
  type        = list(string)
  description = "Required; The name of the DynamoDb table(s) used to track state locks."
}
variable "principals" {
  type        = list(string)
  description = "Optional; A list of AWS principals (user/prfix/userId, role/prefix/roleName), that is applied to the bucket policy. Default is \"root\""
  default     = []
}
variable "tags" {
  type        = map(string)
  description = "Optional; A map of tags (key, value) pairs for s3 and dynamodb table"
  default     = {}
}
variable "backup_tags" {
  type        = map(string)
  description = "Optional; Supply a list of tags that are supported by AWS Backup Vault. These tags are applied to the Terraform s3 bucket."
  default     = {}
}
variable "log_bucket" {
  type        = string
  description = "Optional; An s3 bucket where log files will be delivered"
  default     = ""
}
variable "log_prefix" {
  type        = string
  description = "Optional; A prefix placed on log files as they are delivered to the log_bucket"
  default     = "logs/"
}
