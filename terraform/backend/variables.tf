variable "project" {
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
  type = string
}

variable "environment_name" {
  description = "The environment name. e.g. dev, staging, prod"
  type = string
  
}
