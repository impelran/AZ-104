variable "resource_group_name" {
  type = string
}

variable "resource_location" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "subnet_address_prefix" {
  type = string
}

variable "nic_name" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
}

variable "image_publisher" {
  type = string
}

variable "image_offer" {
  type = string
}

variable "image_sku" {
  type = string
}

variable "image_version" {
  type = string
}

variable "subscription_id" {
  type = string
}