data "template_file" "values" {
    template = "${file("${path.module}/templates/values.yaml.tpl")}"

    vars {
        elasticsearch_endpoint = "${var.elasticsearch_endpoint}"
        elasticsearch_port     = "${var.elasticsearch_port}"
    }
}
