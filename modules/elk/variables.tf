variable "aws_region" {
  type = "string"
}

variable "domain" {
  type = "string"
}

variable "ebs_size" {
  default = 10
}

variable "elasticsearch_port" {
  default = 443
}

variable "elasticsearch_version" {
  default = "6.4"
}

variable "curator_enabled" {
  default = true
}

variable "curator_chart_version" {
  default = "1.2.1"
}

variable "curator_namespace" {
  default = "logging"
}

variable "curator_release_name" {
  default = "elasticsearch-curator"
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

variable "kibana_chart_version" {
  default = "1.6.0"
}

variable "kibana_release_name" {
  default = "kibana"
}

variable "kibana_namespace" {
  default = "default"
}

variable "kibana_version" {
  default = "6.4.3"
}

variable "selfhosted_kibana_enabled" {
  description = "Enable deploy Kibana to the Kubernetes cluster "
  default     = true
}

variable "subnet_ids" {
  type = "list"
}

variable "vpc_id" {
  type = "string"
}
