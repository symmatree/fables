# CoreDNS Mixin

Prometheus monitoring mixin for CoreDNS; generates dashboards and alerts. Deployed via Tanka/Jsonnet into kube-system namespace.

## Configuration

- **Short summary**: CoreDNS mixin generates Prometheus Operator and Grafana resources for CoreDNS monitoring. Deployed via Tanka (jsonnet-via-tanka) from in-repo tanka environment; deploys to kube-system.
- **application.yaml type**: jsonnet-via-tanka
- **Where loaded from**: In-repo path tanka, environment coredns-mixin.
- **Version deployed**: main (repo targetRevision)
- **Links**:
  - Application: [application.yaml](https://github.com/symmatree/tiles/blob/main/tanka/environments/coredns-mixin/application.yaml)
  - [main.jsonnet](https://github.com/symmatree/tiles/blob/main/tanka/environments/coredns-mixin/main.jsonnet)
  - [spec.json](https://github.com/symmatree/tiles/blob/main/tanka/environments/coredns-mixin/spec.json)
- **TF / bootstrap values**: Yes. Variables used: cluster_name, vault_name, project_id (via plugin parameters). No dedicated .tf; values from app-of-apps. TF: [k8s-cluster](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster).
- **Tanka**: Environment `tanka/environments/coredns-mixin`. Links above.
- **Varies between prod and test**: Yes. Configuration varies by environment (cluster_name, vault_name, project_id).

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*
