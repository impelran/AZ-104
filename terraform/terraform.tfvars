# Azure
subscription_id = "a1f37475-cbc7-47b3-8b51-0b9b3029c847"
resource_location = "francecentral"

# Resource Group
resource_group_name = "TP1"

# Networking
vnet_name           = "TP1-vnet"
vnet_address_space  = "10.0.0.0/16"
subnet_name         = "TP1-subnet"
subnet_address_prefix = "10.0.1.0/24"
nic_name            = "TP1-nic"
public_ip_name      = "TP1-public-ip"
nsg_name            = "TP1-nsg"
dns_label           = "mon-vm-romain-eysines"

# Virtual Machine
vm_name              = "TP1-vm"
vm_size              = "Standard_B1s"
admin_username       = "azureuser"
public_key_path      = "~/.ssh/cloud_tp1_key.pub"
os_disk_name         = "TP1-os-disk"

# Source Image
image_publisher = "Canonical"
image_offer     = "0001-com-ubuntu-server-focal"
image_sku       = "20_04-lts"
image_version   = "latest"

# Storage
storage_account_name = "tp1storageromain"
storage_container_name = "tp1-data"

# My IP
my_public_ip = "91.160.185.229"

# Monitoring
alert_email_address = "cmpnn.romain@gmail.com"