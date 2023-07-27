variable "region" {
  type = string
}

variable "project_id" {
}


variable "network_name" {
  default = "usc1-trust-vpc-001"
}

variable "subnet_name1" {
  default = "usc1-trustsubnet-001"
}

variable "subnet_ip" {
  default = "10.10.0.0/24"
}

variable "subnet_private_access" {
  type = bool
  default = true
}

variable "subnet_flow_logs" {
  type = bool
  default = false
}
