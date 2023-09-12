# This module provisions the GCP infrastructure needed inside an Apigee X 'gateway' project
# This will (eventually) provision

# Apigee Service Identity account
# KMS for Apigee Org
# KMS for Apigee Org's instances
# TODO-Either Bridge MIG's or Bridge NEG's (TBD) with load balancer
# TODO-Public HTTPS Google Cloud Load Balancer

# Provision service identity
# resource "google_project_service_identity" "apigee_sa" {
#   provider = google-beta
#   project  = var.project_id
#   service  = "apigee.googleapis.com"
# }

# Key ring for an Apigee Org
# module "kms-org-db" {
#   source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/kms?ref=v16.0.0"
#   project_id = var.project_id
#   key_iam = {
#     org-db = {
#       "roles/cloudkms.cryptoKeyEncrypterDecrypter" = ["serviceAccount:${google_project_service_identity.apigee_sa.email}"]
#     }
#   }
#   keyring = {
#     location = "us" #var.ax_region for multi region Apigee X just put 'us' as location
#     # ref https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli#multi-region
#     name = var.apigee_org_kms_keyring_name
#   }
#   keys = {
#     org-db = { rotation_period = var.org_key_rotation_period, labels = null }
#   }
# }

# # Key rings for each of an Apigee Org's instances
# module "kms-inst-disk" {
#   for_each   = var.apigee_instances
#   source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/kms?ref=v16.0.0"
#   project_id = var.project_id
#   key_iam = {
#     inst-disk = {
#       "roles/cloudkms.cryptoKeyEncrypterDecrypter" = ["serviceAccount:${google_project_service_identity.apigee_sa.email}"]
#     }
#   }
#   keyring = {
#     location = each.value.region
#     name     = "apigee-${each.key}"
#   }
#   keys = {
#     inst-disk = { rotation_period = var.instance_key_rotation_period, labels = null }
#   }
# }

