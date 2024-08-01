
variable "VM_COUNT" {
  type    = number
  default = 1
}

variable "LOCATION_SSH_PUBLIC_KEY" {
  type = string
}

variable "LOCATION_SSH_PRIVATE_KEY" {
  type = string
}


variable "DO_API_TOKEN" {
  type      = string
  sensitive = true
}
