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

locals {
  # A map of our VMs to easily loop over them
  vms_for_monitoring = {
    proxy   = module.proxy_vm
    website = module.website_vm
    db      = module.db_vm
  }

  # A map defining the alerts we want to create
  alert_definitions = {
    cpu = {
      metric_name = "Percentage CPU"
      operator    = "GreaterThan"
      threshold   = 70
      description = "Alert when CPU usage exceeds 70%"
    },
    ram = {
      metric_name = "Available Memory Bytes"
      operator    = "LessThan"
      threshold   = 536870912 # 512 MiB
      description = "Alert when available RAM drops below 512 MiB"
    }
  }

  # Combine VMs and alerts into a single map for the for_each loop
  # This creates entries like "proxy-cpu", "proxy-ram", "website-cpu", etc.
  vm_alerts = {
    for tuple in setproduct(keys(local.vms_for_monitoring), keys(local.alert_definitions)) :
    "${tuple[0]}-${tuple[1]}" => {
      vm_key      = tuple[0]
      alert_key   = tuple[1]
      vm_module   = local.vms_for_monitoring[tuple[0]]
      alert_props = local.alert_definitions[tuple[1]]
    }
  }
}

# Create all alerts using a single resource block
resource "azurerm_monitor_metric_alert" "vm_alerts" {
  for_each            = local.vm_alerts
  name                = "${each.value.alert_key}-alert-${each.value.vm_module.vm_name}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [each.value.vm_module.vm_id]
  description         = "${each.value.alert_props.description} on the ${each.value.vm_key} VM"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = each.value.alert_props.metric_name
    aggregation      = "Average"
    operator         = each.value.alert_props.operator
    threshold        = each.value.alert_props.threshold
  }

  window_size = "PT5M"
  frequency   = "PT1M"

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }
}