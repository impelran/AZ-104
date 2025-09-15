# Create an Azure Key Vault
resource "azurerm_key_vault" "main" {
  name                = "kv-${var.resource_group_name}-romain"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Access policy to grant permissions to the current user (you)
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Set",
      "Get",
      "List",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}

# Generate a random password
resource "random_password" "main" {
  length  = 16
  special = true
  override_special = "!@#$%^&*()-_=+"
}

# Store the random password as a secret in the Key Vault
resource "azurerm_key_vault_secret" "main" {
  name         = "random-secret"
  value        = random_password.main.result
  key_vault_id = azurerm_key_vault.main.id
}