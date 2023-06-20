terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.4.0"
    }
  }
}

provider "vsphere" {
  user           = "administrator@csc-jsc.com"
  password       = "Nutanix/4u"
  vsphere_server = "csc-vcenter.csc-jsc.com"
  allow_unverified_ssl = true
}
data "vsphere_datacenter" "datacenter" {
  name = "CSC-Gara"
}

data "vsphere_host" "host" {
  name          = "esxi-hpe01.csc-jsc.com"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

data "vsphere_distributed_virtual_switch" "vds" {
  name          = "vDSwitch-for-CSC Gara"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_distributed_port_group" "dvpg" {
  name                            = "dvpg-01"
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.vds.id

  active_uplinks  = [data.vsphere_distributed_virtual_switch.vds.uplinks[0]]
  standby_uplinks = [data.vsphere_distributed_virtual_switch.vds.uplinks[1]]


  vlan_id = 200
}

resource "vsphere_host_virtual_switch" "switch" {
  name           = "vSwitchTerraformTest"
  host_system_id = "${data.vsphere_host.host.id}"

  network_adapters = ["vmnic2", "vmnic3"]

  active_nics  = ["vmnic2"]
  standby_nics = ["vmnic3"]
}