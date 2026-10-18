output "storage_account_name" {
  value = azurerm_storage_account.data.name
}

output "blob_endpoint" {
  value = azurerm_storage_account.data.primary_blob_endpoint
}

output "container_urls" {
  description = "Locations for raw images, masks and model artifacts, consumed via configuration (not hardcoded)."
  value       = { for key, container in azurerm_storage_container.this : key => "${azurerm_storage_account.data.primary_blob_endpoint}${container.name}" }
}
