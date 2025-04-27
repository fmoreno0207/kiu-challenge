#variables
# Región donde se desplegarán los recursos
variable "region" {
  type = string
}

# CIDR para la VPC
variable "cidr" {
  type = string
  default = "10.0.0.0/16"
}

# Zonas de disponibilidad
variable "azs" {
  type = list(string)
  default = [   "us-east-1a", 
                "us-east-1b", 
                "us-east-1c"    ]
}

# CIDR para las subnets públicas
variable "subnets-ips" {
  type = list(string)
  default = [   "10.0.1.0/24",
                "10.0.3.0/24",
                "10.0.5.0/24"  ]
}


# CIDR para las subnets privadas
variable "priv-subnets-ips" {
  type = list(string)
  default = [
    "10.0.7.0/24",
    "10.0.9.0/24",
    "10.0.10.0/24"
  ]
}

# Nombre del proyecto
variable "project" {
  description = "Nombre del proyecto"
  type = string
}

# Nombre del entorno (dev, staging, prod)
variable "environment_name" {
  description = "Environment"
  type        = string
}

