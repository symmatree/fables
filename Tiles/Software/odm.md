# ODM (WebODM)

WebODM or related ODM workload; deployed via Tanka/Jsonnet from in-repo environment. Uses NFS for datasets.

## Configuration

- **Short summary**: ODM (e.g. WebODM) deployed via Tanka (jsonnet-via-tanka) from in-repo environment tanka/environments/odm; uses NFS for datasets.
- **application.yaml type**: jsonnet-via-tanka
- **Where loaded from**: In-repo path tanka, environment odm.
- **Version deployed**: main (repo targetRevision)
- **Links**:
  - Application: [application.yaml](https://github.com/symmatree/tiles/blob/main/tanka/environments/odm/application.yaml)
  - [main.jsonnet](https://github.com/symmatree/tiles/blob/main/tanka/environments/odm/main.jsonnet)
  - [spec.json](https://github.com/symmatree/tiles/blob/main/tanka/environments/odm/spec.json)
- **TF / bootstrap values**: Yes. Variables used: cluster_name, vault_name, nfs_server, datasets_nfs_path (via app_settings). No dedicated .tf; values from app-of-apps. TF: [k8s-cluster](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster).
- **Tanka**: Environment `tanka/environments/odm`. Links above.
- **Varies between prod and test**: Yes. Configuration varies by environment (cluster_name, vault_name, nfs_server, datasets_nfs_path, ingress hostname).

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*
