# Azure
variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID."
}

variable "resource_location" {
  type        = string
  description = "The Azure region for the resources."
}

# Resource Group
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

# Networking
variable "vnet_name" {
  type        = string
  description = "Name of the virtual network."
}

variable "vnet_address_space" {
  type        = string
  description = "Address space for the virtual network."
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet."
}

variable "subnet_address_prefix" {
  type        = string
  description = "Address prefix for the subnet."
}

# Virtual Machine
variable "vm_size" {
  type        = string
  description = "Size of the virtual machine."
}

variable "admin_username" {
  type        = string
  description = "Administrator username for the VM."
}

variable "public_key_path" {
  type        = string
  description = "Path to the SSH public key."
}

# Source Image
variable "image_publisher" {
  type        = string
  description = "Publisher of the source image."
  default     = "Canonical"
}

variable "image_offer" {
  type        = string
  description = "Offer of the source image."
  default     = "0001-com-ubuntu-server-focal"
}

variable "image_sku" {
  type        = string
  description = "SKU of the source image."
  default     = "20_04-lts"
}

variable "image_version" {
  type        = string
  description = "Version of the source image."
  default     = "latest"
}

# My IP
variable "my_public_ip" {
  type        = string
  description = "Your public IP for SSH access."
}

# Monitoring
variable "alert_email_address" {
  type        = string
  description = "Email address for alerts."
}