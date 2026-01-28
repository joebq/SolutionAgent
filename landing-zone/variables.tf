variable "resource_group_name" {
  description = "Name of the resource group for the landing zone"
  type        = string
  default     = "rg-landing-zone"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-landing-zone"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "gateway_subnet_prefix" {
  description = "Address prefix for the gateway subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "bastion_subnet_prefix" {
  description = "Address prefix for the bastion subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "vm_subnet_name" {
  description = "Name of the VM subnet"
  type        = string
  default     = "snet-vms"
}

variable "vm_subnet_prefix" {
  description = "Address prefix for the VM subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "vpn_gateway_name" {
  description = "Name of the VPN gateway"
  type        = string
  default     = "vng-landing-zone"
}

variable "vpn_gateway_sku" {
  description = "SKU for the VPN gateway"
  type        = string
  default     = "VpnGw1"
}

variable "bastion_name" {
  description = "Name of the Azure Bastion"
  type        = string
  default     = "bastion-landing-zone"
}

variable "bastion_sku" {
  description = "SKU for Azure Bastion"
  type        = string
  default     = "Basic"
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = "vm-landing-zone"
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vm_availability_zone" {
  description = "Availability zone for the virtual machine"
  type        = string
  default     = null
}

variable "vm_admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
  default     = "azureadmin"
}

variable "windows_server_sku" {
  description = "Windows Server SKU"
  type        = string
  default     = "2022-Datacenter"
}

variable "allowed_rdp_source_address" {
  description = "Source address prefix allowed for RDP access (e.g., your public IP or * for all - not recommended for production)"
  type        = string
  default     = "*"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "LandingZone"
    ManagedBy   = "Terraform"
    Purpose     = "Azure Landing Zone Demo"
  }
}

variable "enable_telemetry" {
  description = "Enable telemetry for AVM modules"
  type        = bool
  default     = true
}
