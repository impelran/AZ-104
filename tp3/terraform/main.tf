# Configuration du fournisseur Azure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_location
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_address_prefix]
}

# Create the virtual machines in the correct order to resolve dependencies
module "db_vm" {
  source              = "./vm_module"
  vm_name             = "db-vm"
  role                = "db"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet.id
  public_key_path     = var.public_key_path
  admin_username      = var.admin_username
  vm_size             = var.vm_size
  my_public_ip        = var.my_public_ip
  image_publisher     = var.image_publisher
  website_ip          = module.website_vm.private_ip # Pass website IP to DB for NSG rule
  key_vault_name      = azurerm_key_vault.kv.name
  db_user_secret_name = azurerm_key_vault_secret.db_user.name
  db_password_secret_name = azurerm_key_vault_secret.db_password.name
  image_offer         = var.image_offer
  image_sku           = var.image_sku
  image_version       = var.image_version
}

module "website_vm" {
  source              = "./vm_module"
  vm_name             = "website-vm"
  role                = "website"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet.id
  public_key_path     = var.public_key_path
  admin_username      = var.admin_username
  vm_size             = var.vm_size
  my_public_ip        = var.my_public_ip
  database_ip         = module.db_vm.private_ip
  key_vault_name      = azurerm_key_vault.kv.name
  django_secret_name  = azurerm_key_vault_secret.django_secret.name
  db_user_secret_name = azurerm_key_vault_secret.db_user.name
  db_password_secret_name = azurerm_key_vault_secret.db_password.name
  image_publisher     = var.image_publisher
  image_offer         = var.image_offer
  image_sku           = var.image_sku
  image_version       = var.image_version
}

module "proxy_vm" {
  source              = "./vm_module"
  vm_name             = "proxy-vm"
  role                = "proxy"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet.id
  public_key_path     = var.public_key_path
  admin_username      = var.admin_username
  vm_size             = var.vm_size
  my_public_ip        = var.my_public_ip
  website_ip          = module.website_vm.private_ip
  image_publisher     = var.image_publisher
  image_offer         = var.image_offer
  image_sku           = var.image_sku
  image_version       = var.image_version
}

resource "azurerm_network_security_rule" "allow_website_to_db" {
  name                        = "AllowFromWebsite"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5432"
  source_address_prefix       = module.website_vm.private_ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = module.db_vm.nsg_name
}

resource "azurerm_network_security_rule" "allow_proxy_to_website" {
  name                        = "AllowFromProxy"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8000"
  source_address_prefix       = module.proxy_vm.private_ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = module.website_vm.nsg_name
}