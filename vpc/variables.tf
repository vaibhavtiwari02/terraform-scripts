variable "vpc-name" {
  type        = string
  description = "enter a name for VPC"
}

variable "vpc-cidr" {
  type        = string
  description = "enter the vpc cidr"
}

variable "region" {
  type        = string
  description = "enter the region to create the resources into"
}

variable "subnet-cidr" {
  type        = list(string)
  description = "enter all the subnet cidr"
}