terraform {
  required_version = ">= 1.0"
}

locals {
  data = yamldecode(file("routes.yaml"))
}
# module "sbux-cdx-dev-routing-apigw-dev" {
#   source     = "../../modules/internet-neg"
#   project_id = "sbux-cdx-dev"


#   internet_neg_fqdn                = local.data.cdx-dev
#   internet_neg_port                = "443"
#   internet_neg_apigee_x_host_paths = local.data.cdx-dev.dev-edge.cdx.starbucks.com
# }
# module "sbux-cdx-dev-routing-eapi-sd" {
#   source     = "../../modules/internet-neg"
#   project_id = "sbux-cdx-dev"


#   internet_neg_fqdn                = local.data.cdx-dev
#   internet_neg_port                = "443"
#   internet_neg_apigee_x_host_paths = local.data.cdx-dev.eapi-master-edge.starbucks.com
# }
# module "sbux-cdx-dev-routing-test14" {
#   source     = "../../modules/internet-neg"
#   project_id = "sbux-cdx-dev"


#   internet_neg_fqdn                = local.data.cdx-dev
#   internet_neg_port                = "443"
#   internet_neg_apigee_x_host_paths = local.data.cdx-dev.oapi-master-edge.starbucks.com
# }

# module "my-module" {
#   for_each = { for k, v in local.data.hosts.my-site : k => v }
#   source   = "./my-module"
#   host     = each.key
#   fqdn     = each.value
# }

/*module "sbux-integration-routing" {
  # for_each = local.data.hosts.sbux-integration
  # for k in local.data.hosts.subx-integration : host => k
  # for_each = tomap(local.data.hosts.sbux-integration)
  for_each = { for k, v in local.data.hosts.sbux-integration : k => v }

  source = "../../modules/internet-neg"
  project_id = "sbux-integration"

  internet_neg = each.value.neg
  internet_fqdn = each.value.fqdn
  more_things = each.value.more-things
}*/

/*
module "sbux-portal-dev-routing" {
  # for_each = local.data.hosts.sbux-integration
  # for k in local.data.hosts.subx-integration : host => k
  # for_each = tomap(local.data.hosts.sbux-integration)
  for_each = { for k, v in local.data.hosts.sbux-portal-dev : k => v }

  source = "../../modules/project-infra"
  project_id = "sbux-portal-dev"
  internet_neg = each.value.neg
  internet_neg_fqdn= each.value.fqdn
  internet_neg_port                = "443"
  //internet_neg_fqdn = each.value.fqdn
  #internet_apigw-routes = each.value.apigw-routes
  internet_neg_apigee_x_host_paths = tomap ({"test14.openapi.starbucks.com"="/v1/websocket"})
  secret_project_id = "apigee-shared-resources-bc85"
  //more_things = each.value.more-things
}
*/

/*module "sbux-integration-routing" {
  source     = "../../modules/internet-neg"
  project_id = "sbux-integration"

  internet_neg_fqdn                = local.data.integration
  internet_neg_port                = "443"
  internet_neg_apigee_x_host_paths = local.data.integration.eapi-master-edge.starbucks.com
}*/

/*
## Notes ## 
 - Has the module on line 92 recently been modified to parse routes.yaml file 
  - How are the routes being passed in the module i.e (/cidi-cache/*)
*/


module "sbux-cdx-dev-routing" {
  # for_each = local.data.hosts.sbux-integration
  # for k in local.data.hosts.subx-integration : host => k
  # for_each = tomap(local.data.hosts.sbux-integration)

  for_each = { for k, v in local.data.cdx-dev : k => v }
  source ="./project-infra" #"./modules/project-infra"
  project_id = "sbux-cdx-dev"
  internet_neg_name=replace(each.value.fqdn, ".","-")  
  //internet_neg = each.value.neg //apigw-dev.starbucks.com
  internet_neg_fqdn= each.value.fqdn  //dev-edge.cdx.starbucks.com  #### Not being used by URL Map - Only by google_compute_global_network_endpoint
  internet_neg_port                = "443"
  //internet_neg_apigee_x_host_paths = each.value.host-paths

###########
# Start here: Main piece of code for hosts being passed to the host_path_map
###########

  internet_neg_apigee_x_host_paths={"apigw1-dev.starbucks.com" = ["/users/me/customer/*","/v1/oauth/token"]} 
  //tomap ({(each.value.neg) = (each.value.apigw-routes)})
  # secret_project_id = "apigee-shared-resources-bc85"
  //more_things = each.value.more-things
}



module "sbux-integration-routing" {
  # for_each = local.data.hosts.sbux-integration
  # for k in local.data.hosts.subx-integration : host => k
  # for_each = tomap(local.data.hosts.sbux-integration)

  for_each = { for k, v in local.data.sbux-integration : k => v }
  source = "./project-infra"#"./modules/project-infra"
  project_id = "sbux-integration"
  internet_neg_name=replace(each.value.fqdn, ".","-")
  //internet_neg = each.value.neg //apigw-dev.starbucks.com
  internet_neg_fqdn= each.value.fqdn  //dev-edge.cdx.starbucks.com
  internet_neg_port                = "443"
  internet_neg_apigee_x_host_paths = each.value.host-paths

  //internet_neg_apigee_x_host_paths={"apigw1-dev.starbucks.com" = ["/users/me/customer/*","/v1/oauth/token"]}
  //tomap ({(each.value.neg) = (each.value.apigw-routes)})
  # secret_project_id = "apigee-shared-resources-bc85"
  //more_things = each.value.more-things
}

# resource "google_compute_url_map" "urlmap-temp" {
#   for_each = { for k, v in local.data.cdx-dev : k => v }

#   name        = "urlmap-temp"
#   description = "a description"

#   default_service = google_compute_backend_service.psc_backend

#   host_rule {
#     hosts        = [each.value.host-paths]
#     path_matcher = "allpaths"
#   }

#   path_matcher {
#     name            = "allpaths"
#     default_service = google_compute_backend_service.psc_backend

#     path_rule {
#       paths   = [each.value]
#       service = google_compute_backend_service.psc_backend
#     }
#   }
# }
