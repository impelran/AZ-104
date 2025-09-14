# Create a Storage Account
resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create a Storage Container
resource "azurerm_storage_container" "main" {
  name                  = var.storage_container_name
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

# Assign role to the VM for storage access
resource "azurerm_role_assignment" "main" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_virtual_machine.main.identity.0.principal_id
  depends_on           = [azurerm_linux_virtual_machine.main]
}