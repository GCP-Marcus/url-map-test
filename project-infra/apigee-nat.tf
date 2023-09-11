# Reserve an external IP address for each Apigee X instance to use as a NAT IP
# Ref. https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/apigee_nat_address

resource "google_apigee_nat_address" "apigee-nat" {
  count       = length(var.apigee_instances_list)
  name        = "apigeex-nat-ip-${count.index}"
  instance_id = var.apigee_instances_list[count.index]

  # Regex extracts the subsring to the right of the final / , ie the name of the instance
  #name = "apigeex-nat-ip-${regex(".*/([^/]+)$", instance_id, 1)}"
  #name = "apigeex-nat-ip-%{random_suffix()}"
}
