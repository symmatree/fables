# Alloy - Telemetry Collector

Grafana Alloy deployment using the [k8s-monitoring](https://github.com/grafana/k8s-monitoring-helm) Helm chart to collect metrics and logs from the Kubernetes cluster and forward them to Mimir and Loki.

## Configuration

- **Short summary**: Grafana Alloy deployed via the k8s-monitoring Helm chart; collects metrics and logs from the cluster and forwards to Mimir and Loki. Deployed via Helm from Grafana helm-charts repo.
- **application.yaml type**: helm
- **Where loaded from**: Helm chart `k8s-monitoring` from https://grafana.github.io/helm-charts
- **Version deployed**: 3.7.1
- **Links**:
  - Application: [alloy-application.yaml](https://github.com/symmatree/tiles/blob/main/charts/argocd-applications/templates/alloy-application.yaml)
  - (No values.yaml in repo; values in Application valuesObject.)
- **TF / bootstrap values**: Yes. Variables used: cluster_name, vault_name. No dedicated .tf for this component; values from app-of-apps. TF: [k8s-cluster](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster).
- **Varies between prod and test**: Yes. Configuration varies by environment (cluster_name, vault_name differ per cluster).

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*

## Configuration Design

- **k8s-monitoring chart**: Values and behavior are defined in the Application's `valuesObject`; there is no separate values file in the repo. Upstream chart documentation: [k8s-monitoring-helm](https://github.com/grafana/k8s-monitoring-helm).

## Architecture

This deployment runs multiple Alloy instances:

- **alloy-metrics**: Scrapes cluster and application metrics, includes embedded blackbox exporter
- **alloy-singleton**: Handles PrometheusRules synchronization to Mimir ruler
- **alloy-logs**: Collects pod logs from `/var/log/pods`

All instances run with clustering enabled for high availability.

## Key Features

### Metrics Collection

- Scrapes cluster metrics (kubelet, control plane, node-exporter)
- Respects Prometheus Operator CRDs: `PodMonitors`, `ServiceMonitors`, and `Probes`
- kube-proxy metrics disabled (Cilium replaces kube-proxy)
- Blackbox exporter embedded in alloy-metrics instance

### Log Collection

- Collects pod logs from `/var/log/pods`
- Node logs disabled (Talos doesn't surface them through the filesystem)
- Cluster events enabled with JSON format (for proper escaping)

### PrometheusRules

- `alloy-singleton` instance sends `PrometheusRules` to Mimir ruler via `mimir.rules.kubernetes` component
- Rules are discovered from Prometheus Operator CRDs

### Tenant Configuration

- Tenant ID for both Mimir and Loki: cluster name (from `cluster_name` value)
- Loki authentication: HTTP basic auth using `http_user` (cluster name) and `http_passwd` from `loki-tenant-auth` secret
- Mimir uses tenant ID only (no additional auth required)

## Security

- Trust bundle mounted for SSL certificate validation (`trust-bundle` ConfigMap)
- Runs with privileged pod security policy (required for log collection and node metrics)

## Integrations

Self-monitoring enabled for:

- Alloy instances (metrics, singleton, logs)
- cert-manager

Additional integrations can be enabled via the `integrations` section in `values.yaml`.
