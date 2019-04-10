module "keycloak" {
  source        = "modules/keycloak"
  realm_name    = "${var.project_prefix}"
  root_domain   = "${var.project_fqdn}"
  ldap_password = "${var.ldap_password}"
  ldap_bind_dn  = "${var.ldap_bind_dn}"
  ldap_host     = "${var.ldap_host}"
  users_dn      = "${var.users_dn}"
}
