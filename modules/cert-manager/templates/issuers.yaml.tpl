apiVersion: certmanager.k8s.io/v1beta1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${email}
    privateKeySecretRef:
      name: letsencrypt-prod
    dns01:
      providers:
      - name: aws
        route53:
          region: ${aws_region}
---
apiVersion: certmanager.k8s.io/v1beta1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: ${email}
    privateKeySecretRef:
      name: letsencrypt-staging
    dns01:
      providers:
      - name: aws
        route53:
          region: ${aws_region}
