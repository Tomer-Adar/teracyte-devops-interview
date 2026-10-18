resource "azurerm_resource_group" "storage" {
  name     = "${var.name_prefix}-storage-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "data" {
  name                     = "${var.name_prefix}data"
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = var.replication_type
  access_tier              = "Hot"

  # Private: no anonymous blob access, no shared keys (Entra ID / workload identity only), TLS 1.2+.
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"

  blob_properties {
    # Lets a deleted or overwritten model release be recovered; images expire by policy anyway.
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

locals {
  containers = {
    raw    = "raw-images"
    masks  = "masks"
    models = "model-artifacts"
  }
}

resource "azurerm_storage_container" "this" {
  for_each              = local.containers
  name                  = each.value
  storage_account_id    = azurerm_storage_account.data.id
  container_access_type = "private"
}

# Image retention only. The model-artifacts container has no rule: releases are kept until removed deliberately.
resource "azurerm_storage_management_policy" "retention" {
  storage_account_id = azurerm_storage_account.data.id

  rule {
    name    = "raw-images-hot-cool-delete"
    enabled = true
    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["${local.containers.raw}/"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = var.raw_hot_days
        delete_after_days_since_modification_greater_than       = var.raw_delete_days
      }
      version {
        delete_after_days_since_creation = var.raw_delete_days
      }
    }
  }

  rule {
    name    = "masks-delete"
    enabled = true
    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["${local.containers.masks}/"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.mask_delete_days
      }
      version {
        delete_after_days_since_creation = var.mask_delete_days
      }
    }
  }
}
