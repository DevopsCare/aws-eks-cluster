service:
  annotations:
    fabric8.io/expose: "true"
    fabric8.io/ingress.annotations: "kubernetes.io/ingress.class: nginx\ncertmanager.k8s.io/cluster-issuer: letsencrypt-prod"
    fabric8.io/ingress.name: kibana
  externalPort: "5601"

env:
  ELASTICSEARCH_URL: ${elasticsearch_endpoint}

image:
  tag: "${kibana_version}"
