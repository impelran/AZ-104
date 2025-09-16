output "vm_id" {
  description = "The ID of the virtual machine."
  value       = azurerm_linux_virtual_machine.vm.id
}

output "nsg_name" {
  description = "The name of the network security group."
  value       = azurerm_network_security_group.nsg.name
}

output "private_ip" {
  description = "The private IP address of the VM."
  value       = azurerm_network_interface.nic.private_ip_address
}

output "public_ip" {
  description = "The public IP address of the VM (if applicable)."
  value       = local.public_ip_required ? azurerm_public_ip.public_ip[0].ip_address : null
}

output "public_dns" {
  description = "The public FQDN of the VM (if applicable)."
  value       = local.public_ip_required ? azurerm_public_ip.public_ip[0].fqdn : null
}

output "identity" {
  description = "The identity of the virtual machine."
  value       = azurerm_linux_virtual_machine.vm.identity
}

output "vm_name" {
  description = "The name of the virtual machine."
  value       = var.vm_name
}