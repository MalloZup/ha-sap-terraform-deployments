resource "null_resource" "drbd_provisioner" {
  count = var.provisioner == "salt" ? var.drbd_count : 0

  triggers = {
    iscsi_id = join(",", azurerm_virtual_machine.drbd.*.id)
  }

  connection {
    host        = element(local.provisioning_addresses, count.index)
    type        = "ssh"
    user        = var.admin_user
    private_key = file(var.private_key_location)

    bastion_host        = var.bastion_host
    bastion_user        = var.admin_user
    bastion_private_key = file(var.bastion_private_key)
  }

  provisioner "file" {
    content     = <<EOF
provider: azure
role: drbd_node
name_prefix: vm${var.name}
hostname: vm${var.name}0${count.index + 1}
network_domain: ${var.network_domain}
additional_packages: []
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules), ), )}}
authorized_keys: [${trimspace(file(var.public_key_location))}]
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
drbd_disk_device: /dev/sdc
drbd_cluster_vip: ${var.drbd_cluster_vip}
sbd_enabled: ${var.sbd_enabled}
sbd_storage_type: ${var.sbd_storage_type}
sbd_lun_index: 2
iscsi_srv_ip: ${var.iscsi_srv_ip}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitoring_enabled: ${var.monitoring_enabled}
qa_mode: ${var.qa_mode}
partitions:
  1:
    start: 0%
    end: 100%
  EOF
    destination = "/tmp/grains"
  }
}

module "drbd_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.provisioner == "salt" ? var.drbd_count : 0
  instance_ids         = null_resource.drbd_provisioner.*.id
  user                 = var.admin_user
  private_key_location = var.private_key_location
  bastion_host         = var.bastion_host
  bastion_private_key  = var.bastion_private_key
  public_ips           = local.provisioning_addresses
  background           = var.background
}
