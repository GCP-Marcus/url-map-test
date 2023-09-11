/**
 * Copyright 2022 Google LLC
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

locals {
  backend_service_1_created = length(keys(google_compute_backend_service.psc_backend)) > 1
}

# resource "google_compute_backend_service" "psc_backend" {
#   provider              = google-beta
#   for_each              = var.psc_negs
#   project               = var.project_id
#   name                  = "${var.name}-backend-${each.key}"
#   port_name             = "https"
#   protocol              = "HTTPS"
#   load_balancing_scheme = "EXTERNAL_MANAGED"
#   security_policy       = var.security_policy

#   backend {
#     group = each.value
#   }

  # backend {
  #   group = var.psc_negs
  # }

  # dynamic "backend" {
  #   for_each = var.psc_negs
  #   content {
  #     group = backend.value
  #   }
  # }

  # lifecycle {
  #   create_before_destroy = true
  # }

  # Added this for Starbucks, not in original code copied from open source repo
  # log_config {
  #   enable      = true
  #   sample_rate = 1.0
  # }

  # WARNING outlier_detection settings below should not be relied upon for use in a production environment and may need testing and tuning
  # Ref. https://cloud.google.com/load-balancing/docs/https/setting-up-global-traffic-mgmt#configure_outlier_detection
  # Ref https://cloud.google.com/compute/docs/reference/rest/v1/backendServices
  # outlier_detection {

  #   # The base time that a host is ejected for. 
  #   # The real ejection time is equal to the base ejection time multiplied by the number of times the host has been ejected. 
  #   # Defaults to 30000ms or 30s.
  #   #
  #   # The number of seconds for the base ejection time (30s) might be too short or too long, 
  #   # depending on the specifics of the deployment and the tolerance for errors.      
  #   base_ejection_time {
  #     nanos   = 0
  #     seconds = 30
  #   }

  #   # Number of errors before a host is ejected from the connection pool. 
  #   # When the backend host is accessed over HTTP, a 5xx return code qualifies as an error. 
  #   # Defaults to 5.
  #   consecutive_errors = 5

  #   # The number of consecutive gateway failures (502, 503, 504 status or connection errors that are mapped to one of those status codes) 
  #   # before a consecutive gateway failure ejection occurs. 
  #   # Defaults to 3.
  #   consecutive_gateway_failure = 3

  #   # The percentage chance that a host will be actually ejected when an outlier status is detected through consecutive 5xx. 
  #   # This setting can be used to disable ejection or to ramp it up slowly. 
  #   # Defaults to 0.
  #   enforcing_consecutive_errors = 100

  #   # The percentage chance that a host will be actually ejected when an outlier status is detected through consecutive gateway failures. 
  #   # This setting can be used to disable ejection or to ramp it up slowly. 
  #   # Defaults to 100.
  #   enforcing_consecutive_gateway_failure = 100

  #   # The percentage chance that a host will be actually ejected when an outlier status is detected through success rate statistics. 
  #   # This setting can be used to disable ejection or to ramp it up slowly. 
  #   # Defaults to 100.
  #   enforcing_success_rate = 100

  #   # Time interval between ejection analysis sweeps. 
  #   # This can result in both new ejections as well as hosts being returned to service. Defaults to 1 second.
  #   #
  #   # The interval of 1 second between ejection analysis sweeps might be too short, leading to frequent ejections and re-additions of hosts.
  #   # If you only have two hosts and the traffic volume is low, you may consider setting the interval to a higher value, 
  #   # such as 5 or 10 seconds, to reduce overhead. 
  #   # You can adjust the interval based on your specific needs and monitor performance to determine the best value. 
  #   #
  #   # If you have two hosts with high traffic volume, you may want to consider a shorter interval setting for outlier detection in order 
  #   # to more quickly detect and address any issues with the hosts. 
  #   # This would help minimize the impact of any potential outlier behavior on the overall system performance and stability. 
  #   # A shorter interval setting might also allow for more fine-grained monitoring and control of the hosts, 
  #   # allowing you to quickly identify and correct any performance issues.   
  #   interval {
  #     nanos   = 0
  #     seconds = 1 # Keeping this at 1 for now as we expect high traffic volume
  #   }

  #   # Maximum percentage of hosts in the load balancing pool for the backend service that can be ejected. 
  #   # Defaults to 50%.
  #   max_ejection_percent = 50

  #   # The minimum number of total requests that must be collected in one interval (as defined by the interval duration above) 
  #   # to include this host in success rate based outlier detection. 
  #   # If the volume is lower than this setting, outlier detection via success rate statistics is not performed for that host. 
  #   # Defaults to 100.
  #   success_rate_request_volume = 100

  #   # This factor is used to determine the ejection threshold for success rate outlier ejection. 
  #   # The ejection threshold is the difference between the mean success rate, and the product of this factor 
  #   # and the standard deviation of the mean success rate: mean - (stdev * successRateStdevFactor). 
  #   # This factor is divided by a thousand to get a double. 
  #   # That is, if the desired factor is 1.9, the runtime value should be 1900. 
  #   # Defaults to 1900.
  #   success_rate_stdev_factor = 1900

  #   # The number of hosts in a cluster that must have enough request volume to detect success rate outliers. 
  #   # If the number of hosts is less than this setting, outlier detection via success rate statistics is not performed for any host in the cluster. 
  #   # Defaults to 5.
  #   #
  #   # The default value is 5, but if you only have two hosts, you could set it to 1 or 2. 
  #   # Setting it to a lower value may result in the detection of outliers based on a smaller number of hosts, 
  #   # which could result in more frequent ejections or false detections of outliers. 
  #   # However, setting it to a higher value may result in a lower sensitivity to outliers, 
  #   # as the detection is based on a larger number of hosts, which could result in fewer false detections 
  #   # but also in a slower response to outliers. 
  #   # The best setting for this option will depend on your specific use case, such as the traffic volume and the desired level of sensitivity to outliers.
  #   #
  #   # If the number of hosts falls below the success_rate_minimum_hosts setting, then success rate statistics will not be performed for any host in the cluster
  #   # and outlier detection based on success rate will not be used as the basis for ejection. 
  #   # Instead, outlier detection will be based on other factors such as consecutive 5xx errors or consecutive gateway failures, 
  #   # as configured in the consecutive_errors and consecutive_gateway_failure settings.
  #   success_rate_minimum_hosts = 2

  # }
  # End WARNING
# }

/*
## Notes ## - 9/6/23
  - Where are routhes.yaml file being referenced and assinged to host_path_map variable?
      A: Routes/Traffic-Routing.tf file is parsing routes.yaml and passing variables to project-infra/ingress.tf file 
              -- Allows arguments to be passed to nb-psc-17xlb file 
*/


resource "google_compute_url_map" "url_map" { 
  project         = var.project_id
  name            = var.name
  default_service = local.backend_service_1_created ? google_compute_backend_service.psc_backend["internet-neg"].id : google_compute_backend_service.psc_backend["psc-neg"].id

  dynamic "host_rule" {
    for_each = var.host_path_map
    content {
      hosts        = [host_rule.key]
      path_matcher = replace(host_rule.key, ".", "")
    }
  }

  dynamic "path_matcher" {
    for_each = var.host_path_map

    content {
      name              = replace(path_matcher.key, ".", "")
      default_service   = google_compute_backend_service.psc_backend["internet-neg"].id

      dynamic "path_rule" {
        for_each = path_matcher.value

        content {
          paths   = [path_rule.value]
          service = google_compute_backend_service.psc_backend["psc-neg"].id
        }
      }
    }
  }
}


# resource "google_compute_target_https_proxy" "https_proxy" {
#   project          = var.project_id
#   name             = "${var.name}-proxy"
#   url_map          = google_compute_url_map.url_map.id
#   ssl_certificates = var.ssl_certificate
# }

# resource "google_compute_global_forwarding_rule" "forwarding_rule" {
#   project               = var.project_id
#   name                  = "${var.name}-fr"
#   target                = google_compute_target_https_proxy.https_proxy.id
#   ip_address            = var.external_ip != null ? var.external_ip : null
#   port_range            = "443"
#   load_balancing_scheme = "EXTERNAL_MANAGED"
#   labels                = var.labels
# }
