variable "name_prefix" {
  description = "Prefix for resource names; storage account names must be 3-24 lowercase alphanumerics in total."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,16}$", var.name_prefix))
    error_message = "name_prefix must be 3-16 lowercase letters or digits."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "replication_type" {
  description = "LRS is the cost-conscious default; ZRS/GRS for higher durability."
  type        = string
  default     = "LRS"
}

variable "raw_hot_days" {
  description = "Days raw images stay in the hot tier before moving to cool."
  type        = number
  default     = 7
}

variable "raw_delete_days" {
  description = "Days after which raw images are deleted."
  type        = number
  default     = 30
}

variable "mask_delete_days" {
  description = "Days after which masks are deleted (they stay hot until then)."
  type        = number
  default     = 30
}

variable "tags" {
  type    = map(string)
  default = { project = "experiments", managed_by = "terraform" }
}
