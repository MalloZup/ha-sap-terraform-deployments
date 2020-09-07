resource "null_resource" "provision_background" {
  count = var.background ? var.node_count : 0
  triggers = {
    triggers = join(",", var.instance_ids)
  }

  connection {
    host        = element(var.public_ips, count.index)
    type        = "ssh"
    user        = var.user
    password    = var.password
    private_key = var.private_key_location != "" ? file(var.private_key_location) : ""

    bastion_host        = var.bastion_host
    bastion_user        = var.user
    bastion_private_key = var.bastion_private_key != "" ? file(var.bastion_private_key) : ""
  }

  provisioner "file" {
    source      = "${path.module}/../../salt"
    destination = "/tmp"
  }

  provisioner "file" {
    source      = "${path.module}/../../pillar"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "nohup sudo sh /tmp/salt/provision.sh -l /var/log/provisioning.log > /dev/null 2>&1 &",
      "return_code=$? && sleep 1 && exit $return_code",
    ] # Workaround to let the process start in background properly
  }
}

resource "null_resource" "provision" {
  count = ! var.background ? var.node_count : 0
  triggers = {
    triggers = join(",", var.instance_ids)
  }

  connection {
    host        = element(var.public_ips, count.index)
    type        = "ssh"
    user        = var.user
    password    = var.password
    private_key = var.private_key_location != "" ? file(var.private_key_location) : ""

    bastion_host        = var.bastion_host
    bastion_user        = var.user
    bastion_private_key = var.bastion_private_key != "" ? file(var.bastion_private_key) : ""
  }

  provisioner "file" {
    source      = "${path.module}/../../salt"
    destination = "/tmp"
  }

  provisioner "file" {
    source      = "${path.module}/../../pillar"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh /tmp/salt/provision.sh -sol /var/log/provisioning.log",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "[ -f /var/run/reboot-needed ] && echo \"Rebooting the machine...\" && (nohup sudo sh -c 'systemctl stop sshd;/sbin/reboot' &) && sleep 5",
    ]
    on_failure = continue
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh /srv/salt/provision.sh -pdql /var/log/provisioning.log",
    ]
  }
}

resource "null_resource" "post-run" {
  count = ! var.background ? var.node_count : 0
  triggers = {
    triggers = join(",", var.instance_ids)
  }

  connection {
    host        = element(var.public_ips, count.index)
    type        = "ssh"
    user        = var.user
    password    = var.password
    private_key = var.private_key_location != "" ? file(var.private_key_location) : ""

    bastion_host        = var.bastion_host
    bastion_user        = var.user
    bastion_private_key = var.bastion_private_key != "" ? file(var.bastion_private_key) : ""
  }

    provisioner "remote-exec" {
    inline = [
      "if [ -e /var/log/salt-phases.log ]; then sudo sh cat /var/log/salt-phases.log; fi"
     ]
  }
}
