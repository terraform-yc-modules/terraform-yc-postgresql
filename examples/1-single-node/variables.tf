variable "network_id" {
  description = "PostgreSQL cluster network id"
  type        = string
}

variable "subnet_id" {
  description = "PostgreSQL cluster subnet id"
  type        = string
  # Isn't necessarily to set the subnet_id if there's the only subnet in the availability zone
  default = null
}
