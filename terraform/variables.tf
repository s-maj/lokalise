variable "name" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "azs" {
  type = list(string)
}

variable "cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "active_deployment" {
  type = string
}

variable "deployments" {
  type = map(string)
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "tags" {
  type    = map(string)
  default = {}
}