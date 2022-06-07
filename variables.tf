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
