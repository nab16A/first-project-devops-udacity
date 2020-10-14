variable "subscriptionId" {
	type = string
	default = "your-subscription-id"
}

variable "tenantId" {
	type = string
	default = "your-tenant-id"
}

variable "resource_group_name" {
	description = "Name of the resource group."
	type = string
	default = "finalgroup-rg"
}

variable "location" {
	type = string
	default = "northeurope"
}

variable "vnet_name" {
	description = "Name of the vnet to create"
	type = string
	default = "project-vnet"
}

variable "address_space" {
	type = list(string)
	default = ["10.0.0.0/16"]
	description = "The address space used by the virtual network."
}

variable "dns_serv" {
	type = list(string)
	default = ["1.1.1.1", "1.0.0.1"]
	description = "List of IP addresses of DNS servers"
}

variable "subnet_addr_pref" {
	type = list(string)
	default = ["10.0.80.0/20"]
	description = "The address prefix to use for the subnet."
}

variable "usr" {
	type = string
	default = "adminuser"
}

variable "pwd" {
	type = string
	default = "P@ssw0rd1234!"
}

variable "vm_id" {
	type = string
	default = "/subscriptions/64c9682c-ca80-483b-b031-ae4bdaf3e808/resourceGroups/project-rg/providers/Microsoft.Compute/images/projectPackerImage"
}

variable "vm_count" {
	description = "How many number of VMs to create (minimum 2 and no more than 5): "
	type = number
	validation {
		condition = can(regex("2|3|4|5", var.vm_count))
		error_message = "The condition did not meet."
	}
}

variable "tags"	{
	description = "A map of the tags to use for the resources that are deployed"
	type = map(string)
	
	default = {
		environment = "projectcode"
	}
}






