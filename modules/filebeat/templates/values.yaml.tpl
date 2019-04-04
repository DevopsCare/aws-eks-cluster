config:
  setup.template.enabled: false
  filebeat.registry_flush: 2s
  filebeat.config:
    modules:
      path: $${path.config}/modules.d/*.yml
      reload.enabled: false
    prospectors:
      path: $${path.config}/prospectors.d/*.yml
      reload.enabled: false
  filebeat.prospectors:
  - containers.ids:
    - '*'
    processors:
    - add_kubernetes_metadata:
        in_cluster: true
    - drop_event:
        when:
            equals:
                kubernetes.namespace: logging
    - drop_fields:
        fields: ["beat.hostname", "beat.name", "beat.version", "input.type", "host.name"]
    type: docker
  http.enabled: false
  http.port: 5066
  output.elasticsearch:
    hosts: ["https://${elasticsearch_endpoint}:${elasticsearch_port}"]
    index: "filebeat-%%{+yyyy.MM.dd}"
  output.file:
    enabled: false
  processors:
  - add_cloud_metadata: null
