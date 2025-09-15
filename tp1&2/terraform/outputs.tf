output "vm_public_ip_address" {
  description = "The public IP address of the virtual machine."
  value       = azurerm_public_ip.main.ip_address
}

output "vm_dns_fqdn" {
  description = "The fully qualified domain name (FQDN) of the virtual machine."
  value       = azurerm_public_ip.main.fqdn
}

output "random_secret_value" {
  description = "The random secret stored in Azure Key Vault."
  value       = azurerm_key_vault_secret.main.value
  sensitive   = true
}