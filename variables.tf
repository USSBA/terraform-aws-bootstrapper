variable "bucket_name" {
  type = string
}
variable "bucket_source_account_id" {
  type = string
}
variable "account_ids" {
  type = list(string)
}
variable "lock_table_names" {
  type = list(string)
}
