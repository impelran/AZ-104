output "proxy_vm_public_ip" {
  description = "The public IP address of the proxy virtual machine."
  value       = module.proxy_vm.public_ip
}

output "proxy_vm_public_dns" {
  description = "The public DNS name of the proxy virtual machine."
  value       = module.proxy_vm.public_dns
}

output "website_vm_private_ip" {
  description = "The private IP address of the website virtual machine."
  value       = module.website_vm.private_ip
}

output "db_vm_private_ip" {
  description = "The private IP address of the database virtual machine."
  value       = module.db_vm.private_ip
}