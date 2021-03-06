# Launch SLES-HAE of SLES4SAP cluster nodes

# Availability set for the VMs

resource "azurerm_availability_set" "hana-availability-set" {
  name                        = "avset-hana"
  location                    = var.az_region
  resource_group_name         = azurerm_resource_group.myrg.name
  managed                     = "true"
  platform_fault_domain_count = 2

  tags = {
    workspace = terraform.workspace
  }
}

# iSCSI server VM

resource "azurerm_virtual_machine" "iscsisrv" {
  name                  = "vmiscsisrv"
  location              = var.az_region
  resource_group_name   = azurerm_resource_group.myrg.name
  network_interface_ids = [azurerm_network_interface.iscsisrv.id]
  vm_size               = "Standard_D2s_v3"

  storage_os_disk {
    name              = "disk-iscsisrv-Os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id        = var.iscsi_srv_uri != "" ? join(",", azurerm_image.iscsi_srv.*.id) : ""
    publisher = var.iscsi_srv_uri != "" ? "" : var.iscsi_public_publisher
    offer     = var.iscsi_srv_uri != "" ? "" : var.iscsi_public_offer
    sku       = var.iscsi_srv_uri != "" ? "" : var.iscsi_public_sku
    version   = var.iscsi_srv_uri != "" ? "" : var.iscsi_public_version
  }

  storage_data_disk {
    name              = "disk-iscsisrv-Data01"
    caching           = "ReadWrite"
    create_option     = "Empty"
    disk_size_gb      = "10"
    lun               = "0"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name  = "iscsisrv"
    admin_username = var.admin_user
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = file(var.public_key_location)
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = azurerm_storage_account.mytfstorageacc.primary_blob_endpoint
  }

  tags = {
    workspace = terraform.workspace
  }
}

# Hana Nodes
#
resource "azurerm_virtual_machine" "hana" {
  count                 = var.ninstances
  name                  = "vm${var.name}${var.ninstances > 1 ? "0${count.index + 1}" : ""}"
  location              = var.az_region
  resource_group_name   = azurerm_resource_group.myrg.name
  network_interface_ids = [element(azurerm_network_interface.hana.*.id, count.index)]
  availability_set_id   = azurerm_availability_set.hana-availability-set.id
  vm_size               = var.instancetype

  storage_os_disk {
    name              = "disk-${var.name}${var.ninstances > 1 ? "0${count.index + 1}" : ""}-Os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id        = var.sles4sap_uri != "" ? join(",", azurerm_image.sles4sap.*.id) : ""
    publisher = var.sles4sap_uri != "" ? "" : var.hana_public_publisher
    offer     = var.sles4sap_uri != "" ? "" : var.hana_public_offer
    sku       = var.sles4sap_uri != "" ? "" : var.hana_public_sku
    version   = var.sles4sap_uri != "" ? "" : var.hana_public_version
  }

  storage_data_disk {
    name              = "disk-${var.name}${var.ninstances > 1 ? "0${count.index + 1}" : ""}-Data01"
    managed_disk_type = var.hana_data_disk_type
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = var.hana_data_disk_size
    caching           = var.hana_data_disk_caching
  }

  storage_data_disk {
    name              = "disk-${var.name}${var.ninstances > 1 ? "0${count.index + 1}" : ""}-Data02"
    managed_disk_type = var.hana_data_disk_type
    create_option     = "Empty"
    lun               = 1
    disk_size_gb      = var.hana_data_disk_size
    caching           = var.hana_data_disk_caching
  }

  storage_data_disk {
    name              = "disk-${var.name}${var.ninstances > 1 ? "0${count.index + 1}" : ""}-Data03"
    managed_disk_type = var.hana_data_disk_type
    create_option     = "Empty"
    lun               = 2
    disk_size_gb      = var.hana_data_disk_size
    caching           = var.hana_data_disk_caching
  }

  os_profile {
    computer_name  = "${var.name}${var.ninstances > 1 ? "0${count.index + 1}" : ""}"
    admin_username = var.admin_user
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = file(var.public_key_location)
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = azurerm_storage_account.mytfstorageacc.primary_blob_endpoint
  }

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_virtual_machine" "monitoring" {
  name                  = "vmmonitoring"
  count                 = var.monitoring_enabled == true ? 1 : 0
  location              = var.az_region
  resource_group_name   = azurerm_resource_group.myrg.name
  network_interface_ids = [azurerm_network_interface.monitoring.0.id]
  vm_size               = "Standard_D2s_v3"

  storage_os_disk {
    name              = "disk-monitoring-Os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id        = var.monitoring_uri != "" ? azurerm_image.monitoring.0.id : ""
    publisher = var.monitoring_uri != "" ? "" : var.monitoring_public_publisher
    offer     = var.monitoring_uri != "" ? "" : var.monitoring_public_offer
    sku       = var.monitoring_uri != "" ? "" : var.monitoring_public_sku
    version   = var.monitoring_uri != "" ? "" : var.monitoring_public_version
  }

  storage_data_disk {
    name              = "disk-monitoring-Data01"
    caching           = "ReadWrite"
    create_option     = "Empty"
    disk_size_gb      = "10"
    lun               = "0"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "monitoring"
    admin_username = var.admin_user
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = file(var.public_key_location)
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = azurerm_storage_account.mytfstorageacc.primary_blob_endpoint
  }

  tags = {
    workspace = terraform.workspace
  }
}
