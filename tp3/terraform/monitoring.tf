# Define an action group for alerts, which specifies the notification method.
resource "azurerm_monitor_action_group" "action_group" {
  name                = "ag-${azurerm_resource_group.rg.name}-alerts"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "vm-alerts"

  email_receiver {
    name          = "admin"
    email_address = var.alert_email_address
  }
}

# Create CPU and RAM alerts for each VM
resource "azurerm_monitor_metric_alert" "cpu_alert_proxy" {
  name                = "cpu-alert-${module.proxy_vm.vm_name}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [module.proxy_vm.vm_id]
  description         = "Alert when CPU usage exceeds 70% on the proxy VM"
  severity            = 2 # Severity 2: Warning

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  window_size = "PT5M"
  frequency   = "PT1M"

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }
}

resource "azurerm_monitor_metric_alert" "ram_alert_proxy" {
  name                = "ram-alert-${module.proxy_vm.vm_name}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [module.proxy_vm.vm_id]
  description         = "Alert when available RAM drops below 512 MiB on the proxy VM"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 536870912
  }

  window_size = "PT5M"
  frequency   = "PT1M"

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }
}

resource "azurerm_monitor_metric_alert" "cpu_alert_website" {
  name                = "cpu-alert-${module.website_vm.vm_name}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [module.website_vm.vm_id]
  description         = "Alert when CPU usage exceeds 70% on the website VM"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  window_size = "PT5M"
  frequency   = "PT1M"

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }
}

resource "azurerm_monitor_metric_alert" "ram_alert_website" {
  name                = "ram-alert-${module.website_vm.vm_name}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [module.website_vm.vm_id]
  description         = "Alert when available RAM drops below 512 MiB on the website VM"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 536870912
  }

  window_size = "PT5M"
  frequency   = "PT1M"

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }
}

resource "azurerm_monitor_metric_alert" "cpu_alert_db" {
  name                = "cpu-alert-${module.db_vm.vm_name}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [module.db_vm.vm_id]
  description         = "Alert when CPU usage exceeds 70% on the DB VM"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  window_size = "PT5M"
  frequency   = "PT1M"

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }
}

resource "azurerm_monitor_metric_alert" "ram_alert_db" {
  name                = "ram-alert-${module.db_vm.vm_name}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [module.db_vm.vm_id]
  description         = "Alert when available RAM drops below 512 MiB on the DB VM"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 536870912
  }

  window_size = "PT5M"
  frequency   = "PT1M"

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }
}