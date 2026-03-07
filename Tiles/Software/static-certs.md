# Static Certs

Static Certificate resources (e.g. cluster CA, long-lived certs). Deployed via in-repo Helm chart; uses project `default`, not cluster-specific.

## Configuration

- **Short summary**: Static Certificate resources; deploys from in-repo Helm chart (charts/static-certs).
- **application.yaml type**: helm
- **Where loaded from**: In-repo path charts/static-certs (Helm chart).
- **Version deployed**: main (repo targetRevision)
- **Links**:
  - Application: [application.yaml](https://github.com/symmatree/tiles/blob/main/charts/static-certs/application.yaml)
  - values.yaml: [charts/static-certs/values.yaml](https://github.com/symmatree/tiles/blob/main/charts/static-certs/values.yaml)
- **If hosted in our repo**: In-repo chart; appVersion 0.1.0.
- **TF / bootstrap values**: Yes. Variables used: targetRevision (in Application spec.source). No dedicated .tf; values from app-of-apps. TF: [k8s-cluster](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster).
- **Varies between prod and test**: Yes. targetRevision may differ per deployment.

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*
