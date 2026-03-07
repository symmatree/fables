# Postgres Operator

Zalando Postgres Operator for managing PostgreSQL clusters in Kubernetes. Deployed via Helm from Zalando charts.

## Configuration

- **Short summary**: Zalando Postgres Operator; manages PostgreSQL clusters via CRDs. Deployed via Helm from opensource.zalando.com/postgres-operator.
- **application.yaml type**: helm
- **Where loaded from**: Helm chart `postgres-operator` from https://opensource.zalando.com/postgres-operator/charts/postgres-operator
- **Version deployed**: v1.15.1
- **Links**:
  - Application: [postgres-operator-application.yaml](https://github.com/symmatree/tiles/blob/main/charts/argocd-applications/templates/postgres-operator-application.yaml)
  - (No values.yaml in repo; values in Application valuesObject.)
- **TF / bootstrap values**: Yes. Variables used: cluster_name. No dedicated .tf; values from app-of-apps. TF: [k8s-cluster](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster).
- **Varies between prod and test**: Yes. Configuration varies by environment (cluster_name, db_hosted_zone).

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*
