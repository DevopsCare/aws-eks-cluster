service:
  annotations:
    fabric8.io/expose: "true"
    fabric8.io/ingress.annotations: |-
      kubernetes.io/ingress.class: nginx
      certmanager.k8s.io/cluster-issuer: letsencrypt-prod
    fabric8.io/ingress.name: ${ingress_name}
    fabric8.io/ingress.path: /oauth2

config:
  clientID: ${client_id}
  clientSecret: ${client_secret}
  configFile: |-
    email_domains = [ "*" ]
    cookie_domain = "${root_domain}"
    oidc_issuer_url = "https://${keycloak_domain}/auth/realms/${realm}"
    provider = "oidc"
    whitelist-domain = "${root_domain}"
