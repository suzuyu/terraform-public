variable "project_id" {
  type = string
}

# variable "host_project_id" {
#   type = string
# }

# variable "parent_folder_name" {
#   type = string
# }

variable "folder_name" {
  type = string
}

# variable "billing_account" {
#   type = string
# }

variable "admin_group_email" {
  type = string
}

variable "location" {
  type    = string
  default = "asia-northeast1"
}

variable "logging_retention_days" {
  type    = number
  default = 14
}

variable "log_storage_class" {
  type    = string
  default = "COLDLINE"
}

variable "log_storage_delete_age" {
  type    = string
  default = "90"
}

variable "terraform_state_bucket_name" {
  type = string
}
