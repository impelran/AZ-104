# Define local variables for naming
locals {
  name_prefix = "tp3-${var.role}"
  public_ip_required = var.role == "proxy" ? true : false
  dns_label = var.role == "proxy" ? "${local.name_prefix}-vm" : null
}

# Create a public IP address (only for the proxy VM)
resource "azurerm_public_ip" "public_ip" {
  count               = local.public_ip_required ? 1 : 0
  name                = "${local.name_prefix}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = local.dns_label
}

# Create a network security group (NSG) and rules
resource "azurerm_network_security_group" "nsg" {
  name                = "${local.name_prefix}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Rule for SSH from your IP
  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${var.my_public_ip}/32"
    destination_address_prefix = "*"
  }

  # Rules specific to each role
  dynamic "security_rule" {
    for_each = var.role == "proxy" ? [1] : []
    content {
      name                       = "HTTP"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  dynamic "security_rule" {
    for_each = var.role == "proxy" ? [1] : []
    content {
      name                       = "HTTPS"
      priority                   = 102
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

}

# Create a network interface
resource "azurerm_network_interface" "nic" {
  name                = "${local.name_prefix}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = local.public_ip_required ? azurerm_public_ip.public_ip[0].id : null
  }
}

# Associate NSG to network interface
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create a Linux virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    name                 = "${local.name_prefix}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key_path)
  }

  custom_data = var.role == "website" ? base64encode(templatefile("${path.module}/website-init.sh", { db_ip = var.database_ip, admin_username = var.admin_username })) : (
                var.role == "db" ? base64encode(templatefile("${path.module}/db-init.sh", {})) : (
                var.role == "proxy" ? base64encode(templatefile("${path.module}/proxy-init.sh", { website_ip = var.website_ip, public_dns = azurerm_public_ip.public_ip[0].fqdn })) : null))
}