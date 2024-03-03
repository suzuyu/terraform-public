resource "google_folder_iam_binding" "infrastructure_accessapproval_approver" {
  folder = data.terraform_remote_state.state.outputs.organization_infrastructure_folder_id
  role   = "roles/accessapproval.approver" # https://cloud.google.com/assured-workloads/access-approval/docs/access-control?hl=ja#approve-request

  members = var.infrastructure_approvers_list
}

resource "google_folder_iam_binding" "service_accessapproval_approver" {
  folder = data.terraform_remote_state.state.outputs.organization_service_folder_id
  role   = "roles/accessapproval.approver" # https://cloud.google.com/assured-workloads/access-approval/docs/access-control?hl=ja#approve-request

  members = var.service_approvers_list
}
