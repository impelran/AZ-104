variable "vm_name" {
  type = string
}

variable "role" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "public_key_path" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "my_public_ip" {
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

variable "database_ip" {
  type    = string
  default = null
}

variable "website_ip" {
  type    = string
  default = null
}

variable "proxy_ip" {
  type    = string
  default = null
}