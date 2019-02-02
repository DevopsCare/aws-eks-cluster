variable "kubeconfig" {
  type = "string"
}

variable "sentry_additional_settings" {
  default = ""
}

variable "sentry_release_name" {
  default = "sentry"
}

variable "sentry_chart_version" {
  default = "0.4.1"
}

variable "sentry_namespace" {
  default = "logging"
}
