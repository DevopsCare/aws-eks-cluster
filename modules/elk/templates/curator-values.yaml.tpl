resources:
  limits:
   cpu: 50m
   memory: 64Mi
  requests:
   cpu: 30m
   memory: 32Mi

cronjob:
  successfulJobsHistoryLimit: "2"
  concurrencyPolicy: "Forbid"

configMaps:
  config_yml: |-
    ---
    client:
      hosts:
        - ${elasticsearch_endpoint}
      port: ${elasticsearch_port}
      use_ssl: True
      timeout: 30