variable "infrastructure_email_list" {
  type = list(string)
}

variable "service_email_list" {
  type = list(string)
}

variable "infrastructure_approvers_list" {
  type = list(string)
}

variable "service_approvers_list" {
  type = list(string)
}

variable "organization_terraform_state_workspace" {
  default = "default"
}

variable "organization_terraform_state_bucket_name" {}

variable "organization_terraform_state_prefix" {}
