variable "rgname" {
    type = string
    description = "used for resource group naming"
}

variable "location" {
    type = string
    description = "used for selecting the location"
    default = "eastus"
}

variable "prefix" {
   type = string
   description = "used for networking"
}
variable "vnet_cidr_prefix" {
    type = string
    description = "this variable defined address space for vnet"
}

variable "subnet1_cidr_prefix" {
    type = string 
    description = "this variable defined address space for subnet"
}

variable "subnet" {
   type = string
   description = "this variable defined subnet name"
}







