variable "region" {
  default = "us-east-1"
}

variable "project" {
  default = "dev"
}

variable "cidr_block_vpc" {
  default = "10.0.0.0/16"
}

variable "cidr_block_subnet_public-1a" {
  default = "10.0.64.0/19"
}

variable "cidr_block_subnet_public-1b" {
  default = "10.0.96.0/19"
}

variable "cidr_block_subnet_private-1a" {
  default = "10.0.0.0/19"
}

variable "cidr_block_subnet_private-1b" {
  default = "10.0.32.0/19"
}
