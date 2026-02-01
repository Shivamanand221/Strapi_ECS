variable "aws_region" {}
variable "project_name" {}

variable "instance_type" {
  default = "t3.small"
}

variable "db_name" {}
variable "db_user" {}
variable "db_password" {}

variable "strapi_image" {}