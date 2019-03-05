variable "elasticsearch_endpoint" {
  type = "string"
}

variable "elasticsearch_port" {
  default = 443
}

variable "filebeat_chart_version" {
  default = "1.0.5"
}

variable "filebeat_namespace" {
  default = "logging"
}

variable "release_name" {
  default = "filebeat"
}
