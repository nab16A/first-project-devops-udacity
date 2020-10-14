provider "azurerm" {
	subscription_id = var.subscriptionId
	tenant_id = var.tenantId
	features {}
}

# create a resource group

resource "azurerm_resource_group" "vnetproject" {
  name     	= var.resource_group_name
  location 	= var.location
  tags 		= var.tags
}

resource "azurerm_network_ddos_protection_plan" "vnetproject" { 
  name                = "ddospplan"
  location            = azurerm_resource_group.vnetproject.location
  resource_group_name = azurerm_resource_group.vnetproject.name
}

# create a virtual network within the resource group

resource "azurerm_virtual_network" "vnetproject" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = azurerm_resource_group.vnetproject.location
  resource_group_name = azurerm_resource_group.vnetproject.name
  
  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.vnetproject.id
    enable = true
  }
  tags = var.tags
}

# create a subnet within the virtual network

resource "azurerm_subnet" "internal" {
  count				   = var.vm_count
  name                 = "project-subnet-${format("%02d", count.index + 1)}"
  resource_group_name  = azurerm_resource_group.vnetproject.name
  virtual_network_name = azurerm_virtual_network.vnetproject.name
  address_prefixes     = [var.subnet_addr_pref[0]]
}

# create the resource NSG

resource "azurerm_network_security_group" "vnet" {
	name					= "securityGroup"
	location				= azurerm_resource_group.vnetproject.location
	resource_group_name		= azurerm_resource_group.vnetproject.name
	
	security_rule {
			name							= "network-access-rule"
			priority						= 200
			direction						= "Outbound"
			access							= "Allow"
			protocol						= "*"
			source_port_range				= "*"
			destination_port_range			= "*"
			source_address_prefix			= "10.0.0.0/16"
			destination_address_prefix		= "10.0.0.0/16"
		}
		
	security_rule	{
			name							= "internet-access-rule"
			direction						= "Inbound"
			access							= "Deny"
			priority						= 300
			source_address_prefix			= "Internet"
			source_port_range				= "*"
			destination_address_prefix		= "10.0.0.0/16"
			destination_port_range			= "*"
			protocol						= "*"
		}
	tags				   			= var.tags
}

# associates a NSG with a Subnet within a Virtual Network

resource "azurerm_subnet_network_security_group_association" "vnetproject" {
  count						= var.vm_count  
  subnet_id                 = azurerm_subnet.internal.*.id[count.index]
  network_security_group_id = azurerm_network_security_group.vnet.id
}

# create a network interface

resource "azurerm_network_interface" "vnetproject" {
    count				= var.vm_count
	name				= "vnetproject-nic"
	location			= azurerm_resource_group.vnetproject.location
	resource_group_name = azurerm_resource_group.vnetproject.name
	
	ip_configuration {
		name							= "projectipconfiguration"
		subnet_id						= azurerm_subnet.internal.*.id[count.index]
		private_ip_address_allocation	= "Dynamic"
	}
}

# create a public IP for Linux

resource "azurerm_public_ip" "vnetproject" {
  name				   		= "public-ip"
  location			   		= azurerm_resource_group.vnetproject.location
  resource_group_name  		= azurerm_resource_group.vnetproject.name
  allocation_method	   		= "Static"
  idle_timeout_in_minutes   = 30
  tags = var.tags
}

resource "azurerm_lb" "vnetproject" {
  name                = "LoadBalancer"
  location            = var.location
  resource_group_name = azurerm_resource_group.vnetproject.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vnetproject.id
  }
  tags					 = var.tags
}

resource "azurerm_lb_backend_address_pool" "vnetproject" {
  resource_group_name = azurerm_resource_group.vnetproject.name
  loadbalancer_id     = azurerm_lb.vnetproject.id
  name                = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "vnetproject" {
  count					  = var.vm_count
  network_interface_id    = azurerm_network_interface.vnetproject.*.id[count.index]
  ip_configuration_name   = "projectipconfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.vnetproject.id
}

resource "azurerm_managed_disk" "managed_disk" {
  count                = var.vm_count
  name                 = "project-disk-${format("%02d", count.index + 1)}"
  location             = azurerm_resource_group.vnetproject.location
  resource_group_name  = azurerm_resource_group.vnetproject.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "md_attach" {
  count				 = var.vm_count
  managed_disk_id    = azurerm_managed_disk.managed_disk.*.id[count.index]
  virtual_machine_id = azurerm_linux_virtual_machine.vnetproject.*.id[count.index]
  lun                = "10"
  caching            = "ReadWrite"
}

# Linux virtual machine

resource "azurerm_linux_virtual_machine" "vnetproject" {
  count							  = var.vm_count
  name                            = "project-vm-${format("%02d", count.index + 1)}"
  resource_group_name             = azurerm_resource_group.vnetproject.name
  location                        = var.location
  size                            = "Standard_D2_v3"
  admin_username                  = var.usr 
  admin_password                  = var.pwd 
  network_interface_ids 		  = [element(azurerm_network_interface.vnetproject.*.id, count.index)]
  disable_password_authentication = false
  
  source_image_id = var.vm_id
    
  os_disk {
    name				 = "project-osdisk-${format("%02d", count.index + 1)}"
	storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  tags = var.tags
}