# Postgres Operator UI

Web UI for the Zalando Postgres Operator. Deployed via Helm using the **`postgres-operator-ui`** chart index (a sibling of the main operator chart URL, not the same `index.yaml`).

## Configuration

- **Short summary**: Postgres Operator UI; web interface for managing Postgres clusters. Deployed via Helm from the dedicated UI chart repository (see below).
- **application.yaml type**: helm
- **Where loaded from**: Helm chart `postgres-operator-ui` from https://opensource.zalando.com/postgres-operator/charts/postgres-operator-ui
- **Version deployed**: 1.15.1 (Helm chart version string; not prefixed with `v`)
- **Links**:
  - Application: [postgres-operator-ui-application.yaml](https://github.com/symmatree/tiles/blob/main/charts/argocd-applications/templates/postgres-operator-ui-application.yaml)
  - (No values.yaml in repo; values in Application valuesObject.)
- **TF / bootstrap values**: Yes. Variables used: cluster_name. No dedicated .tf; values from app-of-apps. TF: [k8s-cluster](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster).
- **Varies between prod and test**: Yes. Configuration varies by environment (cluster_name, ingress hostname).

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*
