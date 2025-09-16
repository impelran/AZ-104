data "azurerm_client_config" "current" {}

resource "random_string" "kv_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_string" "django_secret" {
  length  = 50
  special = true
}

resource "random_string" "db_user" {
  length  = 12
  special = false
}

resource "random_password" "db_password" {
  length  = 24
  special = true
}

resource "azurerm_key_vault" "kv" {
  name                        = "kv-${var.resource_group_name}-${random_string.kv_suffix.result}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  rbac_authorization_enabled = true
}

# Grant the Terraform user admin rights on the Key Vault
resource "azurerm_role_assignment" "terraform_user_kv_admin" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Grant the website VM's managed identity rights to read secrets
resource "azurerm_role_assignment" "website_vm_kv_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.website_vm.identity[0].principal_id
}

# Grant the DB VM's managed identity rights to read secrets
resource "azurerm_role_assignment" "db_vm_kv_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.db_vm.identity[0].principal_id
}

resource "azurerm_key_vault_secret" "django_secret" {
  name         = "django-secret-key"
  value        = random_string.django_secret.result
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.terraform_user_kv_admin]
}

resource "azurerm_key_vault_secret" "db_user" {
  name         = "db-user"
  value        = random_string.db_user.result
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.terraform_user_kv_admin]
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = random_password.db_password.result
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.terraform_user_kv_admin]
}
