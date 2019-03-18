keycloak:
  service:
    annotations:
      fabric8.io/expose: "true"
      fabric8.io/ingress.annotations: "kubernetes.io/ingress.class: nginx\ncertmanager.k8s.io/cluster-issuer: letsencrypt-prod"
      fabric8.io/ingress.name: ${ingress_name}
  password: ${password}
  username: ${username}
  persistence:
    deployPostgres: true
    dbVendor: postgres
