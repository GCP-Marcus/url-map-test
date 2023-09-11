/*
## Notes ##
 - Need to find what is being passed into "instance_service_attachments" variable
 -   
*/



locals {
  ssl_certificates = [
    for cert in data.google_secret_manager_secret_version.certs :
      {
        name        = nonsensitive(jsondecode(cert.secret_data)["name"])
        certificate = jsondecode(cert.secret_data)["certificate"]
        private_key = jsondecode(cert.secret_data)["private_key"]
      }
  ]

  internet_neg_created = length(google_compute_global_network_endpoint_group.internet_negs) > 0
}

data "google_secret_manager_secret_version" "certs" {
  for_each = toset(var.ssl_certificates)
  project  = var.secret_project_id
  secret   = each.value
  version  = "latest"
}

# Classic self managed cert
resource "google_compute_ssl_certificate" "ssl_certificates" {
  for_each = { for cert in local.ssl_certificates : cert.name => cert }

  project     = var.project_id
  name        = each.value.name
  description = each.value.name
  private_key = base64decode(each.value.private_key)
  certificate = base64decode(each.value.certificate)

  lifecycle {
    create_before_destroy = true
  }
}

# Create Internet NEGs
resource "google_compute_global_network_endpoint_group" "internet_negs" {
  count                 = length(var.internet_neg_fqdn) > 0 ? 1 : 0
  project               = var.project_id
  name                  = var.internet_neg_name
  //name                  = join("internet-neg-apigee-",split(".","${var.internet_neg_fqdn}")[0])
  //name                  = format("internet-neg-apigee-,%s",split(".","${var.internet_neg_fqdn}")[0])
  network_endpoint_type = "INTERNET_FQDN_PORT"
  default_port          = var.internet_neg_port
}

# Create Network Endpoints for Internet NEGs
resource "google_compute_global_network_endpoint" "network_endpoint" {
  count                 = length(var.internet_neg_fqdn) > 0 ? 1 : 0
  project                       = var.project_id
  global_network_endpoint_group = google_compute_global_network_endpoint_group.internet_negs[0].id
  fqdn                          = var.internet_neg_fqdn
  port                          = google_compute_global_network_endpoint_group.internet_negs[0].default_port
}


# Create PSC NEGs for the backend
resource "google_compute_region_network_endpoint_group" "psc_neg" {
  for_each = var.instance_service_attachments

  project = var.project_id
  name    = "psc-neg-us-${each.key}" # Append the region to the name

  region  = each.key # Region is the key 
  network = var.network

  subnetwork = lookup(var.region_networks, each.key) # Finds the subnet for the region

  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"

  psc_target_service = each.value

  lifecycle {
    create_before_destroy = true
  }
}

##########



# Reserve a static external IP address for the Load Balancer
resource "google_compute_global_address" "lb_ip" {

  for_each = var.instance_service_attachments
  project  = var.project_id
  name     = "apigeex-lb-ip-${each.key}"

  # This may be a good idea for now to prevent accidentally losing the IP address. Commenting out due to failure when merging in multiple GLB changes - JT 5/4/23.
  # lifecycle {
  #   prevent_destroy = true
  # }
}

module "nb-psc-l7xlb" {
  # Only provision this if an SSL cert was provided
  #count = length(var.ssl_certificate) > 0 ? 1 : 0

  for_each = var.instance_service_attachments

  depends_on = [
    google_compute_ssl_certificate.ssl_certificates[0]
  ]

  source                  = "../../modules/nb-psc-l7xlb"
  project_id              = var.project_id
  name                    = "apigee-xlb-psc-${each.key}"
  network                 = var.network

  ssl_certificate = [for cert in google_compute_ssl_certificate.ssl_certificates : cert.id] 

  external_ip = google_compute_global_address.lb_ip[each.key].id

  # Checks if internet-neg has been created already, if yes then create a map consisting of psc-neg and internet-neg, if not then create map of psc-neg only 
  psc_negs = local.internet_neg_created ? { for k, v in tomap({"psc-neg" = google_compute_region_network_endpoint_group.psc_neg[each.key].id,"internet-neg" = [ for neg in google_compute_global_network_endpoint_group.internet_negs : neg.id ]}) : k => v } : { for k, v in tomap({"psc-neg" = google_compute_region_network_endpoint_group.psc_neg[each.key].id}) : k => v }
  

  host_path_map = var.internet_neg_apigee_x_host_paths # may need to construct a sample map 
}

