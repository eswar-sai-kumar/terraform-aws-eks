variable "project_name" {
  default = "task2-infra"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Project = "task2-infra"
    Environment = "dev"
    Terraform = "true"
  }
}

variable "zone_name" {
  default = "eswarsaikumar.site"
}