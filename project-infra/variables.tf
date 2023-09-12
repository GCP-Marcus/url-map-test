/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  description = "Project id (also used for the Apigee Organization)."
  type        = string
  default = "direct-branch-378819"
}

# variable "secret_project_id" {
#   description = "Secret Project id (also used for the Apigee Organization)."
#   type        = string
# }

# variable "ax_region" {
#   description = "GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli)."
#   type        = string
# }

#variable "network" {
#  description = "Network (self-link) to peer with the Apigee tennant project."
#  type        = string
#}

#variable "billing_type" {
#  description = "Billing type of the Apigee organization."
#  type        = string
#  default     = null
#}

#variable "apigee_envgroups" {
#  description = "Apigee Environment Groups."
#  type = map(object({
#    environments = list(string)
#    hostnames    = list(string)
#  }))
#  default = {}
#}

#variable "apigee_environments" {
#  description = "Apigee Environment Names."
#  type        = list(string)
#  default     = []
#}

variable "apigee_instances" {
  description = "Apigee Instances."
  type = map(object({
    region = string
  }))
  default = {}
}

#variable "apigee_instances" {
#  description = "Apigee Instances (only one instance for EVAL)."
#  type = map(object({
#    region       = string
#    ip_range     = string
#    environments = list(string)
#  }))
#  default = {}
#}


variable "org_key_rotation_period" {
  description = "Rotaton period for the organization DB encryption key"
  type        = string
  default     = "2592000s"
}

variable "instance_key_rotation_period" {
  description = "Rotaton period for the instance disk encryption key"
  type        = string
  default     = "2592000s"
}

variable "apigee_org_kms_keyring_name" {
  description = "Name of the KMS Key Ring for Apigee Organization DB."
  type        = string
  default     = "apigee-x-org"
}

# Ingress variables
# Needed to provision certificate, external load balancer 
# and private service connect network endpoint group backends (1 in us-west1 and 1 in us-east4)
# If the SSL certificate is not provided (null), the cert and load balancer will not be provisioned
# variable "ssl_certificate" {
#   description = "ssl_certificate for Apigee X proxy external load balancer"
#   type        = string
#   default     = ""
#   nullable    = true
#   sensitive   = true
# }

# variable "ssl_certificate_key" {
#   description = "ssl_certificate key"
#   type        = string
#   default     = ""
#   nullable    = true
#   sensitive   = true # Prevent this from appearing in TF output and logs
# }

variable "network" {
  description = "VPC network"
  type        = string
  default     = "forgerock-network"
  nullable    = true
}

#variable "us_west1_subnet" {
#  description = "subnet for psc"
#  type        = string
#  default     = ""
#  nullable    = true
#}

#variable "us_east4_subnet" {
#  description = "subnet for psc"
#  type        = string
#  default     = ""
#  nullable    = true
#}

# TODO refactor to use the instance_service_attachments instead?
# If this is null, the west psc neg will not be provisioned
#variable "us_west1_psc_svc" {
#  description = "psc svc"
#  type        = string
#  default     = ""
#  nullable    = true
#}

# TODO refactor to use the instance_service_attachments instead?
# If this is null, the east psc neg will not be provisioned
#variable "us_east4_psc_svc" {
#  description = "psc svc"
#  type        = string
#  default     = ""
#  nullable    = true
#}

# Map of region to service attachment ID
# Ref. https://github.com/apigee/terraform-modules/blob/main/modules/nb-psc-l7xlb/README.md#input_psc_service_attachments
variable "instance_service_attachments" {
  description = "VPC network"
  type        = map(string)
  default     = {}
  nullable    = true
}

# Map of region to subnetworks
variable "region_networks" {
  description = "VPC network"
  type        = map(string)
  default     = {}
  nullable    = true
}

# End Ingress variables

# Apigee X NAT variables

# The Apigee instance associated with the Apigee environment, in the format organizations/{{org_name}}/instances/{{instance_name}}.
variable "apigee_instances_list" {
  type    = list(string)
  default = []
}

# SSL Certificates for GLBs
# variable "ssl_certificates" {
#   type = list(object({
#     name        = string
#     certificate = string
#     private_key = string
#   }))
#   default   = []
# }

variable "ssl_certificates" {
  type    = list
  default = []
}

# variable "internet_negs" {
#   type        = list
#   default     = []
#   nullable    = true
# }

variable "internet_neg_fqdn" {
  type        = string
  default     = ""
  nullable    = true
}

variable "internet_neg_port" {
  type        = string
  default     = "443"
  nullable    = true
}

variable "internet_neg_apigee_x_host_paths" {
  type        = map
  default     = {}
  nullable    = true
}

variable "internet_fqdn" {
  type = string 
  default  = ""
  nullable    = true
}

variable "internet_neg" {
  type = string
  default  = ""
  nullable    = true
}

variable "internet_neg_name" {
  type = string
  default  = ""
  nullable    = true
}