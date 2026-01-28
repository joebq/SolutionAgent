output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.landing_zone.name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.vnet.resource_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.vnet.name
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = [var.vnet_address_space]
}

output "vpn_gateway_id" {
  description = "ID of the VPN gateway"
  value       = azurerm_virtual_network_gateway.vpn.id
}

output "vpn_gateway_public_ip" {
  description = "Public IP address of the VPN gateway"
  value       = azurerm_public_ip.vpn_gateway.ip_address
}

output "bastion_id" {
  description = "ID of the Azure Bastion"
  value       = azurerm_bastion_host.main.id
}

output "bastion_dns_name" {
  description = "DNS name of the Azure Bastion"
  value       = azurerm_bastion_host.main.dns_name
}

output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_windows_virtual_machine.main.id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_windows_virtual_machine.main.name
}

output "vm_public_ip" {
  description = "Public IP address of the virtual machine"
  value       = azurerm_public_ip.vm.ip_address
}

output "vm_private_ip" {
  description = "Private IP address of the virtual machine"
  value       = azurerm_network_interface.vm.private_ip_address
}

output "vm_admin_username" {
  description = "Admin username for the virtual machine"
  value       = var.vm_admin_username
}

output "vm_admin_password" {
  description = "Admin password for the virtual machine (sensitive)"
  value       = random_password.vm_admin.result
  sensitive   = true
}

output "rdp_connection_command" {
  description = "Command to connect to VM via RDP using public IP"
  value       = "mstsc /v:${azurerm_public_ip.vm.ip_address}"
}
