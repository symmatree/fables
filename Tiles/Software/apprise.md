# Apprise

Notification gateway; accepts alerts and forwards to many notification backends. Deployed via Tanka/Jsonnet from in-repo environment.

## Configuration

- **Short summary**: Apprise notification service; deploys via Tanka (jsonnet-via-tanka) from in-repo environment tanka/environments/apprise.
- **application.yaml type**: jsonnet-via-tanka
- **Where loaded from**: In-repo path tanka, environment apprise.
- **Version deployed**: main (repo targetRevision)
- **Links**:
  - Application: [application.yaml](https://github.com/symmatree/tiles/blob/main/tanka/environments/apprise/application.yaml)
  - [main.jsonnet](https://github.com/symmatree/tiles/blob/main/tanka/environments/apprise/main.jsonnet)
  - [spec.json](https://github.com/symmatree/tiles/blob/main/tanka/environments/apprise/spec.json)
  - TF: [apprise.tf](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster/apprise.tf)
- **TF / bootstrap values**: Yes. Variables used: cluster_name, vault_name, project_id, targetRevision (and app_settings: hostname, cluster_issuer, apprise_env, apprise_admin). TF: [apprise.tf](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster/apprise.tf).
- **Tanka**: Environment `tanka/environments/apprise`. Links above.
- **Varies between prod and test**: Yes. Configuration varies by environment (cluster_name, vault_name, project_id, hostname, apprise items).

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*
