variable "aws_region" {
  type = "string"
}

variable "common_name" {
  type = "string"
}

variable "email_address" {
  description = "Email will be used for registration via ACME"
}

variable "environment" {
  type = "string"
}

variable "staging" {
  defaut = false
}

variable "subject_alternative_names" {
  type    = "list"
  default = []
}
