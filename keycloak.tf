module "keycloak-master" {
  source        = "modules/keycloak-master"
  root_domain   = "${var.project_fqdn}"
  ldap_password = "${var.ldap_password}"
  ldap_bind_dn  = "${var.ldap_bind_dn}"
  ldap_host     = "${var.ldap_host}"
  users_dn      = "${var.users_dn}"
}
