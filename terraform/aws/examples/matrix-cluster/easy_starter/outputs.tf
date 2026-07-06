locals {
  # The address Volumez uses to reach each node for the installation
  media_mgmt_ips   = var.assign_public_ips ? module.media_nodes.public_ips : module.media_nodes.private_ips
  gateway_mgmt_ips = var.assign_public_ips ? module.gateway_nodes.public_ips : module.gateway_nodes.private_ips

  media_csv_rows = [
    for i in range(var.media_node_count) :
    "daos_servers,${local.media_mgmt_ips[i]},${module.media_nodes.service_ips[i]},${module.media_nodes.hostnames[i]},${module.media_nodes.private_ips[i]}"
  ]

  gateway_csv_rows = [
    for i in range(var.gateway_node_count) :
    "daos_clients,${local.gateway_mgmt_ips[i]},${module.gateway_nodes.service_ips[i]},${module.gateway_nodes.hostnames[i]},${module.gateway_nodes.private_ips[i]}"
  ]
}

# The node mapping the Volumez Matrix installation consumes, one row per node:
# role,mgmt_ip,service_ip,hostname,node_ip
# Copy this output verbatim and deliver it to Volumez.
output "custom_ips_csv" {
  value = join("\n", concat(local.media_csv_rows, local.gateway_csv_rows))
}

output "media_nodes" {
  value = [
    for i in range(var.media_node_count) : {
      hostname   = module.media_nodes.hostnames[i]
      public_ip  = var.assign_public_ips ? module.media_nodes.public_ips[i] : null
      private_ip = module.media_nodes.private_ips[i]
      service_ip = module.media_nodes.service_ips[i]
    }
  ]
}

output "gateway_nodes" {
  value = [
    for i in range(var.gateway_node_count) : {
      hostname   = module.gateway_nodes.hostnames[i]
      public_ip  = var.assign_public_ips ? module.gateway_nodes.public_ips[i] : null
      private_ip = module.gateway_nodes.private_ips[i]
      service_ip = module.gateway_nodes.service_ips[i]
    }
  ]
}

# Linux client + AD DC are NOT part of custom_ips_csv — the Volumez install
# consumes only the storage-cluster mapping; client and DC are handled
# separately during the engagement.
output "client_nodes" {
  value = [
    for i in range(var.client_node_count) : {
      hostname   = module.client_nodes.hostnames[i]
      public_ip  = var.assign_public_ips ? module.client_nodes.public_ips[i] : null
      private_ip = module.client_nodes.private_ips[i]
      service_ip = module.client_nodes.service_ips[i]
    }
  ]
}

output "ad_dc" {
  value = var.enable_ad_dc ? {
    public_ip  = module.ad_dc.public_ip
    private_ip = module.ad_dc.private_ip
  } : null
}

output "ssh_key_name" {
  value = local.key_name
}

output "ssh_private_key" {
  description = "Private key for the generated key pair (empty when key_name was supplied)"
  value       = join("", module.ssh_key[*].key_value)
  sensitive   = true
}

output "mgmt_vpc_id" {
  value = module.network.mgmt_vpc_id
}

output "service_vpc_id" {
  value = module.network.service_vpc_id
}
