terraform {
  required_version = ">= 0.12"
}

resource "libvirt_volume" "base_image" {
  name   = "${terraform.workspace}-baseimage"
  source = var.image
  count  = var.use_shared_resources ? 0 : 1
  pool   = var.pool
}

resource "libvirt_network" "isolated_network" {
  name      = "${terraform.workspace}-isolated"
  mode      = "none"
  addresses = [var.iprange]

  dhcp {
    enabled = "false"
  }

  autostart = true
}

output "configuration" {
  depends_on = [
    libvirt_volume.base_image,
    libvirt_network.isolated_network,
  ]

  value = {
    public_key_location  = var.public_key_location
    domain               = var.domain
    use_shared_resources = var.use_shared_resources
    isolated_network_id  = join(",", libvirt_network.isolated_network.*.id)
    iprange              = var.iprange
    // Provider-specific variables
    pool         = var.pool
    network_name = var.bridge == "" ? var.network_name : ""
    bridge       = var.bridge
  }
}

