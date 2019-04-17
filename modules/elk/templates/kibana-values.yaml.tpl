service:
  annotations:
    fabric8.io/expose: "${expose_enabled}"
    fabric8.io/ingress.annotations: |-
      kubernetes.io/ingress.class: nginx
      certmanager.k8s.io/cluster-issuer: letsencrypt-prod

    %{ if oauth_proxy != "" }
      nginx.ingress.kubernetes.io/auth-signin: https://${oauth_proxy}/oauth2/start?rd=$request_uri
      nginx.ingress.kubernetes.io/auth-url: https://${oauth_proxy}/oauth2/auth
    %{ endif }

    fabric8.io/ingress.name: kibana
  externalPort: "5601"

env:
  ELASTICSEARCH_URL: ${elasticsearch_endpoint}

image:
  tag: "${kibana_version}"
