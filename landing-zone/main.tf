terraform {
  required_version = ">= 1.9.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Resource Group for Landing Zone
resource "azurerm_resource_group" "landing_zone" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Virtual Network using AVM
module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.4.2"

  resource_group_name = azurerm_resource_group.landing_zone.name
  location            = var.location
  name                = var.vnet_name
  address_space       = [var.vnet_address_space]

  subnets = {
    gateway_subnet = {
      name             = "GatewaySubnet"
      address_prefixes = [var.gateway_subnet_prefix]
    }
    bastion_subnet = {
      name             = "AzureBastionSubnet"
      address_prefixes = [var.bastion_subnet_prefix]
    }
    vm_subnet = {
      name             = var.vm_subnet_name
      address_prefixes = [var.vm_subnet_prefix]
    }
  }

  tags             = var.tags
  enable_telemetry = var.enable_telemetry
}

# Public IP for VPN Gateway
resource "azurerm_public_ip" "vpn_gateway" {
  name                = "${var.vpn_gateway_name}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.landing_zone.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# VPN Gateway
resource "azurerm_virtual_network_gateway" "vpn" {
  name                = var.vpn_gateway_name
  location            = var.location
  resource_group_name = azurerm_resource_group.landing_zone.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = false
  sku                 = var.vpn_gateway_sku

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = module.vnet.subnets["gateway_subnet"].resource_id
  }

  tags = var.tags
}

# Public IP for Bastion
resource "azurerm_public_ip" "bastion" {
  name                = "${var.bastion_name}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.landing_zone.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Azure Bastion
resource "azurerm_bastion_host" "main" {
  name                = var.bastion_name
  location            = var.location
  resource_group_name = azurerm_resource_group.landing_zone.name
  sku                 = var.bastion_sku

  ip_configuration {
    name                 = "configuration"
    subnet_id            = module.vnet.subnets["bastion_subnet"].resource_id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = var.tags
}

# Public IP for Virtual Machine
resource "azurerm_public_ip" "vm" {
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.landing_zone.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Network Security Group for VM with RDP access
resource "azurerm_network_security_group" "vm" {
  name                = "${var.vm_name}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.landing_zone.name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.allowed_rdp_source_address
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Network Interface for VM
resource "azurerm_network_interface" "vm" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.landing_zone.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.subnets[var.vm_subnet_name].resource_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }

  tags = var.tags
}

# Associate NSG with Network Interface
resource "azurerm_network_interface_security_group_association" "vm" {
  network_interface_id      = azurerm_network_interface.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

# Random password for VM
resource "random_password" "vm_admin" {
  length           = 16
  special          = true
  override_special = "!@#$%&*()-_=+[]{}:?"
}

# Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "main" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.landing_zone.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = random_password.vm_admin.result

  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.windows_server_sku
    version   = "latest"
  }

  tags = var.tags
}
