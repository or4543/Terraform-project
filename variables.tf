variable "location" {
  description = "The location where the resource group should be created."
  type        = string
  default     = "West Europe" 
}

variable "user_name" {
  description = "The virtual machine login user name"
  type        = string
  default     = "azure_user" 
}
