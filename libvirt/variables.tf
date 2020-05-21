#
# Libvirt related variables
#
variable "qemu_uri" {
  description = "URI to connect with the qemu-service."
  default     = "qemu:///system"
}

variable "storage_pool" {
  description = "libvirt storage pool name for VM disks"
  type        = string
  default     = "default"
}

variable "network_name" {
  description = "Already existing virtual network name. If it's not provided a new one will be created"
  type        = string
  default     = ""
}

variable "iprange" {
  description = "IP range of the isolated network (it must be provided even when the network_name is given, due to terraform-libvirt-provider limitations we cannot get the current network data)"
  type        = string
}

variable "isolated_network_bridge" {
  description = "A name for the isolated virtual network bridge device. It must be no longer than 15 characters. Leave empty to have it auto-generated by libvirt."
  type        = string
  default     = ""
}

variable "source_image" {
  description = "Source image used to boot the machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now. Specific node images have preference over this value"
  type        = string
  default     = ""
}

variable "volume_name" {
  description = "Already existing volume name used to boot the machines. It must be in the same storage pool. It's only used if source_image is not provided. Specific node images have preference over this value"
  type        = string
  default     = ""
}

# Deployment variables
#
variable "reg_code" {
  description = "If informed, register the product using SUSEConnect"
  default     = ""
}

variable "reg_email" {
  description = "Email used for the registration"
  default     = ""
}

# The module format must follow SUSEConnect convention:
# <module_name>/<product_version>/<architecture>
# Example: Suggested modules for SLES for SAP 15
# - sle-module-basesystem/15/x86_64
# - sle-module-desktop-applications/15/x86_64
# - sle-module-server-applications/15/x86_64
# - sle-ha/15/x86_64 (Need the same regcode as SLES for SAP)
# - sle-module-sap-applications/15/x86_64
variable "reg_additional_modules" {
  description = "Map of the modules to be registered. Module name = Regcode, when needed."
  type        = map(string)
  default     = {}
}

# Repository url used to install HA/SAP deployment packages"
# The latest RPM packages can be found at:
# https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/{YOUR OS VERSION}
# Contains the salt formulas rpm packages.
variable "ha_sap_deployment_repo" {
  description = "Repository url used to install HA/SAP deployment packages. If SLE version is not set, the deployment will automatically detect the current OS version"
  type        = string
}

variable "devel_mode" {
  description = "Increase ha_sap_deployment_repo repository priority to get the packages from this repository instead of SLE official channels"
  type        = bool
  default     = false
}

variable "provisioner" {
  description = "Used provisioner option. Available options: salt. Let empty to not use any provisioner"
  default     = "salt"
}

variable "background" {
  description = "Run the provisioner execution in background if set to true finishing terraform execution"
  type        = bool
  default     = false
}

#
# Hana related variables

variable "hana_count" {
  description = "Number of hana nodes"
  type        = number
  default     = 2
}

variable "hana_source_image" {
  description = "Source image used to boot the hana machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now."
  type        = string
  default     = ""
}

variable "hana_volume_name" {
  description = "Already existing volume name used to boot the hana machines. It must be in the same storage pool. It's only used if source_image is not provided"
  type        = string
  default     = ""
}

variable "hana_node_vcpu" {
  description = "Number of CPUs for the HANA machines"
  type        = number
  default     = 4
}

variable "hana_node_memory" {
  description = "Memory (in MBs) for the HANA machines"
  type        = number
  default     = 32678
}

variable "hana_node_disk_size" {
  description = "Disk size (in bytes) for the HANA machines"
  type        = number
  default     = 68719476736
}

variable "hana_ips" {
  description = "ip addresses to set to the hana nodes"
  type        = list(string)
  default     = []
}

variable "hana_inst_media" {
  description = "URL of the NFS share where the SAP HANA software installer is stored. This media shall be mounted in `hana_inst_folder`"
  type        = string
}

variable "hana_inst_folder" {
  description = "Folder where SAP HANA installation files are mounted"
  type        = string
  default     = "/sapmedia/HANA"
}

variable "hana_platform_folder" {
  description = "Path to the hana platform media, relative to the 'hana_inst_media' mounting point"
  type        = string
  default     = ""
}

variable "hana_sapcar_exe" {
  description = "Path to the sapcar executable, relative to the 'hana_inst_media' mounting point"
  type        = string
  default     = ""
}

variable "hana_archive_file" {
  description = "Path to the HANA database server installation SAR archive or HANA platform archive file in zip or rar format, relative to the 'hana_inst_master' mounting point"
  type        = string
  default     = ""
}

variable "hana_extract_dir" {
  description = "Absolute path to folder where SAP HANA archive will be extracted"
  type        = string
  default     = "/sapmedia/HANA"
}

variable "hana_fstype" {
  description = "Filesystem type to use for HANA"
  type        = string
  default     = "xfs"
}

variable "hana_cluster_vip" {
  description = "IP address used to configure the hana cluster floating IP. It must be in other subnet than the machines!"
  type        = string
  default     = ""
}

variable "scenario_type" {
  description = "Deployed scenario type. Available options: performance-optimized, cost-optimized"
  default     = "performance-optimized"
}

#
# iSCSI server related variables
#
variable "iscsi_vcpu" {
  description = "Number of CPUs for the iSCSI server"
  type        = number
  default     = 2
}

variable "iscsi_memory" {
  description = "Memory size (in MBs) for the iSCSI server"
  type        = number
  default     = 4096
}

variable "shared_storage_type" {
  description = "Used shared storage type for fencing (sbd). Available options: iscsi, shared-disk."
  type        = string
  default     = "iscsi"
}

variable "sbd_disk_size" {
  description = "Disk size (in bytes) for the SBD disk"
  type        = number
  default     = 10737418240
}

variable "iscsi_source_image" {
  description = "Source image used to boot the iscsi machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now."
  type        = string
  default     = ""
}

variable "iscsi_volume_name" {
  description = "Already existing volume name used to boot the iscsi machines. It must be in the same storage pool. It's only used if iscsi_source_image is not provided"
  type        = string
  default     = ""
}

variable "iscsi_srv_ip" {
  description = "iSCSI server address (only used if shared_storage_type is iscsi)"
  type        = string
  default     = ""
}

variable "iscsi_disks" {
  description = "Number of partitions attach to iscsi server. 0 means `all`."
  type        = number
  default     = 0
}

#
# Monitoring related variables
#
variable "monitoring_enabled" {
  description = "Enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}

variable "monitoring_source_image" {
  description = "Source image used to boot the monitoring machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now."
  type        = string
  default     = ""
}

variable "monitoring_volume_name" {
  description = "Already existing volume name used to boot the monitoring machines. It must be in the same storage pool. It's only used if monitoring_source_image is not provided"
  type        = string
  default     = ""
}

variable "monitoring_vcpu" {
  description = "Number of CPUs for the monitor machine"
  type        = number
  default     = 4
}

variable "monitoring_memory" {
  description = "Memory (in MBs) for the monitor machine"
  type        = number
  default     = 4096
}

variable "monitoring_srv_ip" {
  description = "Monitoring server address"
  type        = string
  default     = ""
}

#
# Netweaver related variables
#
variable "netweaver_enabled" {
  description = "Enable SAP Netweaver deployment"
  type        = bool
  default     = false
}

variable "netweaver_source_image" {
  description = "Source image used to boot the netweaver machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now."
  type        = string
  default     = ""
}

variable "netweaver_volume_name" {
  description = "Already existing volume name used to boot the netweaver machines. It must be in the same storage pool. It's only used if netweaver_source_image is not provided"
  type        = string
  default     = ""
}

variable "netweaver_node_vcpu" {
  description = "Number of CPUs for the NetWeaver machines"
  type        = number
  default     = 4
}

variable "netweaver_node_memory" {
  description = "Memory (in MBs) for the NetWeaver machines"
  type        = number
  default     = 8192
}

variable "netweaver_shared_disk_size" {
  description = "Shared disk size (in bytes) for the NetWeaver machines"
  type        = number
  default     = 68719476736
}

variable "netweaver_ips" {
  description = "IP addresses of the netweaver nodes"
  type        = list(string)
  default     = []
}

variable "netweaver_virtual_ips" {
  description = "IP addresses of the netweaver nodes"
  type        = list(string)
  default     = []
}

variable "netweaver_nfs_share" {
  description = "URL of the NFS share where /sapmnt and /usr/sap/{sid}/SYS will be mounted. This folder must have the sapmnt and usrsapsys folders"
  type        = string
  default     = ""
}

variable "netweaver_product_id" {
  description = "Netweaver installation product. Even though the module is about Netweaver, it can be used to install other SAP instances like S4/HANA"
  type        = string
  default     = "NW750.HDB.ABAPHA"
}

variable "netweaver_inst_media" {
  description = "URL of the NFS share where the SAP Netweaver software installer is stored. This media shall be mounted in `/sapmedia/NW`"
  type        = string
  default     = ""
}

variable "netweaver_swpm_folder" {
  description = "Netweaver software SWPM folder, path relative from the `netweaver_inst_media` mounted point"
  type        = string
  default     = ""
}

variable "netweaver_sapcar_exe" {
  description = "Path to sapcar executable, relative from the `netweaver_inst_media` mounted point"
  type        = string
  default     = ""
}

variable "netweaver_swpm_sar" {
  description = "SWPM installer sar archive containing the installer, path relative from the `netweaver_inst_media` mounted point"
  type        = string
  default     = ""
}

variable "netweaver_swpm_extract_dir" {
  description = "Extraction path for Netweaver software SWPM folder, if SWPM sar file is provided"
  type        = string
  default     = "/sapmedia/NW/SWPM"
}

variable "netweaver_sapexe_folder" {
  description = "Software folder where needed sapexe `SAR` executables are stored (sapexe, sapexedb, saphostagent), path relative from the `netweaver_inst_media` mounted point"
  type        = string
  default     = ""
}

variable "netweaver_additional_dvds" {
  description = "Software folder with additional SAP software needed to install netweaver (NW export folder and HANA HDB client for example), path relative from the `netweaver_inst_media` mounted point"
  type        = list
  default     = []
}

#
# DRBD related variables
#
variable "drbd_enabled" {
  description = "Enable the drbd cluster for nfs"
  type        = bool
  default     = false
}

variable "drbd_source_image" {
  description = "Source image used to bot the drbd machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now."
  type        = string
  default     = ""
}

variable "drbd_volume_name" {
  description = "Already existing volume name boot to create the drbd machines. It must be in the same storage pool. It's only used if drbd_source_image is not provided"
  type        = string
  default     = ""
}

variable "drbd_count" {
  description = "Number of drbd machines to create the cluster"
  default     = 2
}

variable "drbd_node_vcpu" {
  description = "Number of CPUs for the DRBD machines"
  type        = number
  default     = 1
}

variable "drbd_node_memory" {
  description = "Memory (in MBs) for the DRBD machines"
  type        = number
  default     = 1024
}

variable "drbd_disk_size" {
  description = "Disk size (in bytes) for the DRBD machines"
  type        = number
  default     = 10737418240
}

variable "drbd_shared_disk_size" {
  description = "Shared disk size (in bytes) for the DRBD machines"
  type        = number
  default     = 104857600
}

variable "drbd_ips" {
  description = "IP addresses of the drbd nodes"
  type        = list(string)
  default     = []
}

variable "drbd_cluster_vip" {
  description = "IP address used to configure the drbd cluster floating IP. It must be in other subnet than the machines!"
  type        = string
  default     = ""
}

variable "drbd_shared_storage_type" {
  description = "Used shared storage type for fencing (sbd) for drbd cluster. Available options: iscsi, shared-disk."
  type        = string
  default     = "iscsi"
}

#
# Specific QA variables
#
variable "qa_mode" {
  description = "Enable test/qa mode (disable extra packages usage not coming in the image)"
  type        = bool
  default     = false
}

variable "hwcct" {
  description = "Execute HANA Hardware Configuration Check Tool to bench filesystems"
  type        = bool
  default     = false
}

#
# Pre deployment
#
variable "pre_deployment" {
  description = "Enable pre deployment local execution. Only available for clients running Linux"
  type        = bool
  default     = false
}
