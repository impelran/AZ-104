# Define an action group for alerts, which specifies the notification method.
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-${azurerm_resource_group.main.name}-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "vm-alerts"

  email_receiver {
    name          = "admin"
    email_address = var.alert_email_address
  }
}

# Create a metric alert for the VM's CPU usage.
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "cpu-alert-${azurerm_linux_virtual_machine.main.name}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_linux_virtual_machine.main.id]
  description         = "Alert when CPU usage exceeds 70%"
  severity            = 2 # Severity 2: Warning

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  window_size = "PT5M" # The time period over which the alert will look for data.
  frequency   = "PT1M" # The frequency with which the alert will check for new data.

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Create a metric alert for the VM's RAM usage.
resource "azurerm_monitor_metric_alert" "ram_alert" {
  name                = "ram-alert-${azurerm_linux_virtual_machine.main.name}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_linux_virtual_machine.main.id]
  description         = "Alert when available RAM drops below 512MiB"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 536870912 # 512 MiB in bytes
  }

  window_size = "PT5M" # The time period over which the alert will look for data.
  frequency   = "PT1M" # The frequency with which the alert will check for new data.

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}