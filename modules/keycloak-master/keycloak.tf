resource "helm_release" "keycloak" {
  name      = "${var.keycloak_release_name}"
  chart     = "stable/keycloak"
  namespace = "${var.keycloak_namespace}"
  values    = ["${data.template_file.keycloak-values.rendered}"]
  version   = "${var.keycloak_chart_version}"

  lifecycle {
    ignore_changes = ["keyring"]
  }
}

resource "keycloak_realm" "realm" {
  realm                = "weissr"
  enabled              = true
  access_code_lifespan = "1h"
}

resource "keycloak_ldap_user_federation" "ldap_user_federation" {
  name                    = "ldap"
  realm_id                = "${keycloak_realm.realm.id}"
  enabled                 = true
  username_ldap_attribute = "cn"
  rdn_ldap_attribute      = "cn"
  uuid_ldap_attribute     = "objectGUID"

  user_object_classes = [
    "person",
    "organizationalPerson",
    "user",
  ]

  connection_url     = "${var.ldap_host}"
  users_dn           = "${var.users_dn}"
  bind_dn            = "${var.ldap_bind_dn}"
  bind_credential    = "${var.ldap_password}"
  connection_timeout = "5s"
  read_timeout       = "10s"
  vendor             = "AD"
}
