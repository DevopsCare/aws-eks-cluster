You have to install Install [Keycloak provider](https://mrparkers.github.io/terraform-provider-keycloak/) to use this module. You can use [documentation](https://www.terraform.io/docs/configuration/providers.html#third-party-plugins).


You may have a problem with [Keycloak provider](https://mrparkers.github.io/terraform-provider-keycloak/) because Terraform doesn't support depends_on for providers. In case of you're getting errors related to the keycloak module run:

```bash
terraform apply -target module.keycloak-master.helm_release.keycloak
```

And then:

```bash
terraform apply -target module.keycloak-master
```
