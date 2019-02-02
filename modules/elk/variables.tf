variable "aws_region" {
  type = "string"
}

variable "domain" {
  type = "string"
}

variable "ebs_size" {
  default = 10
}

variable "elasticsearch_version" {
  default = "6.3"
}

variable "instance_count" {
  default = 1
}

variable "instance_type" {
  default = "t2.small.elasticsearch"
}

variable "ip_whitelist" {
  description = "List of IP's which will have an access to Kibana"
  type        = "list"
  default     = []
}
