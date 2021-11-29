terraform {
  required_providers {
    fmc = {
      source = "CiscoDevNet/fmc"
      version = "0.2.1"
    }
  }
}

locals {
  service_ids = transpose({
      for id, s in var.services : id => [s.name]
  })
  grouped = {
      for name, ids in local.service_ids:
      name => [
        for id in ids : var.services[id].address != "" ?
          "${var.services[id].address}" : "${var.services[id].node_address}"
      ]
  }
}

data "fmc_dynamic_objects" "web" {
  name = "web"
}

resource "fmc_dynamic_object_mapping" "test" {
  for_each = local.grouped
  dynamic_object_id = data.fmc_dynamic_objects.web.id
  mappings = each.value
}
