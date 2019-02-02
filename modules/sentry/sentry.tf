resource "helm_release" "sentry" {
  name      = "${var.sentry_release_name}"
  chart     = "stable/sentry"
  namespace = "${var.sentry_namespace}"
  version   = "${var.sentry_chart_version}"

  values = ["${file("${path.root}/values/sentry.yaml")}",
    "${var.sentry_additional_settings}",
  ]

  # set {
  #   name  = "web.env.GITHUB_APP_ID"
  #   value = "${data.vault_generic_secret.sentry.data["github_app_id"]}"
  # }


  # set {
  #   name  = "web.env.GITHUB_API_SECRET"
  #   value = "${data.vault_generic_secret.sentry.data["github_api_secret"]}"
  # }


  # set {
  #   name  = "email.user"
  #   value = "${data.vault_generic_secret.sentry.data["smtp_username"]}"
  # }


  # set {
  #   name  = "email.password"
  #   value = "${data.vault_generic_secret.sentry.data["smtp_password"]}"
  # }


  # set {
  #   name  = "user.password"
  #   value = "${data.vault_generic_secret.sentry.data["sentry_user_password"]}"
  # }


  # set {
  #   name  = "postgresql.postgresPassword"
  #   value = "${data.vault_generic_secret.sentry.data["sentry_postgresql_password"]}"
  # }


  # set {
  #   name  = "redis.password"
  #   value = "${data.vault_generic_secret.sentry.data["sentry_redis_password"]}"
  # }


  # set {
  #   name  = "sentrySecret"
  #   value = "${data.vault_generic_secret.sentry.data["sentry_sentry_secret"]}"
  # }

  lifecycle {
    ignore_changes = ["keyring"]
  }
}
