locals {
  name_prefix        = "tp3-${var.role}"
  public_ip_required = var.role == "proxy" ? true : false
  dns_label          = var.role == "proxy" ? "${local.name_prefix}-vm" : null

  # Ensure this always resolves to a usable DNS name (avoids Bash :- in templates)
  calculated_public_dns = (
    local.public_ip_required && length(azurerm_public_ip.public_ip) > 0
    ? azurerm_public_ip.public_ip[0].fqdn
    : "tp3-proxy-vm.francecentral.cloudapp.azure.com"
  )

  custom_data_map = {
    "website" = templatefile("${path.module}/website-init.sh", {
      db_ip                   = var.database_ip != null ? var.database_ip : ""
      admin_username          = var.admin_username,
      key_vault_name          = var.key_vault_name != null ? var.key_vault_name : "",
      django_secret_name      = var.django_secret_name != null ? var.django_secret_name : "",
      db_user_secret_name     = var.db_user_secret_name != null ? var.db_user_secret_name : "",
      db_password_secret_name = var.db_password_secret_name != null ? var.db_password_secret_name : "",
      allowed_hosts           = join(",", [
        "tp3-proxy-vm.francecentral.cloudapp.azure.com",
        "20.19.169.27",
        "localhost",
        "127.0.0.1",
        azurerm_network_interface.nic.private_ip_address
      ])
    })
    "db" = templatefile("${path.module}/db-init.sh", {
      website_ip              = var.website_ip != null ? var.website_ip : "",
      key_vault_name          = var.key_vault_name != null ? var.key_vault_name : "",
      db_user_secret_name     = var.db_user_secret_name != null ? var.db_user_secret_name : "",
      db_password_secret_name = var.db_password_secret_name != null ? var.db_password_secret_name : ""
    })
    "proxy" = templatefile("${path.module}/proxy-init.sh", {
      website_ip = var.website_ip != null ? var.website_ip : "",
      public_dns = local.calculated_public_dns
    })
  }
}

resource "azurerm_public_ip" "public_ip" {
  count               = local.public_ip_required ? 1 : 0
  name                = "${local.name_prefix}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = local.dns_label
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${local.name_prefix}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

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

  dynamic "security_rule" {
    for_each = var.role == "website" && var.proxy_ip != null ? [1] : []
    content {
      name                       = "Gunicorn"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8000"
      source_address_prefix      = "${var.proxy_ip}/32"
      destination_address_prefix = "*"
    }
  }
}

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

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]

  dynamic "identity" {
    for_each = var.role == "website" || var.role == "db" ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

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

  custom_data = base64encode(lookup(local.custom_data_map, var.role, null))
}
