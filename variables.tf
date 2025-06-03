variable "subscription_id" {
  type = string
}

variable "locations" {
  type = map(string)
}

variable "rgs" {
  type = map(string)
}

variable "vnets" {
  type = map(string)
}

variable "subnets" {
  type = map(string)
}

variable "vms" {
  type = map(string)
}

variable "sgs" {
  type = map(string)
}

variable "nics" {
  type = map(string)
}

variable "sizevm" {
  type = string
}

variable "adminpwd" {
  type = string
}

variable "adminuser" {
  type = string
}

variable "peers" {
  type = map(string)
}