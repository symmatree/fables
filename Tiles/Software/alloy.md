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

The Helm release installs the **Alloy Operator** (`alloy-operator` Deployment) plus `Alloy` custom resources (`collectors.grafana.com/v1alpha1`) rendered as workload pairs below. Operational pods in namespace `alloy` typically include:

| Workload | Kind | Role |
|----------|------|------|
| **alloy-alloy-metrics** | StatefulSet | Cluster and application Prometheus-style scraping (`PodMonitor`/`ServiceMonitor`/`Probe`), kubelet/cAdvisor paths, kube-state-metrics target, embedded **blackbox** exporter (HTTP probes wired from `Probe` CRs), **Prometheus remote write** to **Mimir** |
| **alloy-alloy-singleton** | Deployment | **`mimir.rules.kubernetes`** syncing `PrometheusRule` CRs to **Mimir** ruler (via `extraConfig`); also ships selected telemetry paths from the bundled chart modules |
| **alloy-alloy-logs** | DaemonSet per Linux node | **Pod logs** under `/var/log/pods`; **node/journal logs** when `nodeLogs` is enabled; **cluster events** to Loki (JSON `logFormat`) |
| **alloy-alloy-receiver** | Deployment | **OTLP** gRPC (**4317**) and HTTP (**4318**) for `applicationObservability`; Ingress `otlp.<cluster_name>.symmatree.com` (see Application) terminates TLS and forwards HTTP OTLP |

Supporting chart pods in the same namespace:

- **kube-state-metrics** (Deployment) -- scraped as `integrations/kubernetes/kube-state-metrics` via the chart pipeline into Mimir
- **prometheus-node-exporter** DaemonSet (**release=alloy**) -- scraped as **`integrations/node_exporter`**

Clustering inside Alloy (**headless Service** `alloy-alloy-metrics-cluster`, cluster service logs with `peers_count`) is chart behavior for Alloy clustering. On **tiles-test** the metrics StatefulSet observed **one** ready replica (`peers_count=1`). Multiple replicas scale out scraping and clustering; HA is capability of the chart, not implied by replica count alone.

Cross-check repo source for exact flags: [alloy-application.yaml](https://github.com/symmatree/tiles/blob/main/charts/argocd-applications/templates/alloy-application.yaml).

## Key Features

### Metrics Collection

- Scrapes cluster metrics (kubelet, control plane; kube-state-metrics; node-exporter)
- Respects Prometheus Operator CRDs: `PodMonitors`, `ServiceMonitors`, and `Probes` for workload metrics (not double-scraping Alloy itself; see below).
- kube-proxy metrics disabled (Cilium replaces kube-proxy)
- Blackbox exporter embedded in **alloy-metrics** (Probe targets wired in `extraObjects`)
- **Alloy self-metrics**: **`integrations.alloy`** (`job="integrations/alloy"`) scrapes Alloy pods by label; **ServiceMonitors on the Alloy collectors are disabled** so each Alloy workload is not scraped twice into Mimir. **`alloy-receiver`** is included in **`integrations.alloy`** discovery; extra **`metrics.tuning.includeMetrics`** patterns cover **Grafana alloy-mixin** panels beyond the chart default allow-list.

### Log Collection

- Collects pod logs from `/var/log/pods`
- **Node logs enabled** in the Application (`nodeLogs.enabled: true`) with Talos forwarding into paths the chart tails (journal-style ingestion in Alloy; see upstream Talos logging docs linked in repo comments)
- Cluster events enabled with JSON format (`logFormat: json`)

### OTLP ingress (applications)

- `applicationObservability` receives OTLP metrics and logs (traces disabled in current `valuesObject`); workloads send to in-cluster Service or TLS Ingress host `otlp.<cluster_name>.symmatree.com`

### PrometheusRules

- `alloy-singleton` instance sends PrometheusRules to Mimir ruler via `mimir.rules.kubernetes` component
- Rules are discovered from Prometheus Operator CRDs

### Tenant Configuration

- **`cluster` / `k8s_cluster_name`** on series (remote write / chart metadata): which Kubernetes cluster tenant.
- **`cluster_name`** on Alloy metrics (when nonempty, e.g. on **`alloy-metrics`**): Alloy clustering identity, **not** the same label as Kubernetes cluster name; other collectors may expose **`cluster_name=""`** when clustering is not used for that role.

- Tenant ID for both Mimir and Loki: cluster name (from `cluster_name` value), e.g. `tiles-test` vs `tiles`
- Loki authentication: HTTP basic auth using `http_user` (cluster name) and `http_passwd` from `loki-tenant-auth` secret
- Mimir uses tenant ID only (no additional auth required)

### Grafana datasources (for queries)

Observed on Grafana (per-instance UIDs may vary; Explore lists the live UIDs):

- **Mimir** datasource UID: `prom`
- **Loki** datasource UID: `loki`

Grafana MCP access was re-validated against this setup on **2026-05-09** after token refresh.

## Verification and operations

Substitute **`$CLUSTER`** with the cluster tenant name (**`tiles-test`** or **`tiles`**). Use **Explore** against the datasources above.

### Logs (Loki)

Stream labels observed for Alloy container logs include: `cluster`, `namespace`, `app_kubernetes_io_name`, `job`, `container`, `service_name`.

Example LogQL (component filter by Kubernetes app label exposed as Loki label `app_kubernetes_io_name`):

```logql
{cluster="$CLUSTER", namespace="alloy", app_kubernetes_io_name="alloy-metrics"}
```

```logql
{cluster="$CLUSTER", namespace="alloy", app_kubernetes_io_name="alloy-singleton"}
```

```logql
{cluster="$CLUSTER", namespace="alloy", app_kubernetes_io_name="alloy-logs"}
```

```logql
{cluster="$CLUSTER", namespace="alloy", app_kubernetes_io_name="alloy-receiver"}
```

```logql
{cluster="$CLUSTER", namespace="alloy"} |~ "(?i)(error|level=error|Failed to send)"
```

If label names differ slightly in another environment, open **Explore** `--` label browser for the datasource; `list_loki_label_names` (Grafana MCP) is the scripted equivalent.

Kubernetes **kubectl** (scoped kubeconfig as in repo rules):

```bash
kubectl -n alloy logs -l app.kubernetes.io/name=alloy-metrics -c alloy --tail=100
kubectl -n alloy logs -l app.kubernetes.io/name=alloy-singleton -c alloy --tail=100
kubectl -n alloy logs -l app.kubernetes.io/name=alloy-logs -c alloy --tail=100
kubectl -n alloy logs -l app.kubernetes.io/name=alloy-receiver -c alloy --tail=100
kubectl -n alloy logs deploy/alloy-alloy-operator --tail=100
```

**Normal log patterns (tiles-test observations, hypothesis for similar steady state):**

- **alloy-metrics**: Periodic Alloy graph evaluation traces at `level=info`; **cluster** service lines like `rejoining peers` with `peers_count` matching StatefulSet replicas;Kubernetes client deprecation warnings (**v1 Endpoints**/`EndpointSlice`) from informers appear as **warnings** noise on Kubernetes 1.33+
- **alloy-singleton**: `processing event` lines for **`mimir.rules.kubernetes`** CR changes; occasional **remote_write** resharding **`warn`** entries if timing windows miss thresholds; **Loki.write** / **otelcol** graph nodes during config reload
- **alloy-receiver**: OTLP listeners starting on **4317/4318**; **remote_write** replay and rare **502**/retry warnings if **Mimir** gateway briefly unavailable after startup or rollout
- **alloy-logs**: Graph evaluation **info** lines; **`tail routine`** lifecycle for finished pod logs under `/var/log/pods`; **node_logs** subsystem active when enabled
- **alloy-operator**: JSON **Reconciled release** entries for **`Alloy`** CRs (`alloy-alloy-*`) once per reconcile loop

### Metrics (Mimir)

**Alloy workloads** expose **`job="integrations/alloy"`** for self-metrics (single scrape path). Other **`integrations/*`** jobs (**`node_exporter`**, **`kube-state-metrics`**, cluster scrape jobs) remain as emitted by k8s-monitoring.

Examples:

```promql
up{namespace="alloy"}
```

```promql
up{cluster="$CLUSTER", namespace="alloy"}
```

```promql
alloy_component_controller_running_components{namespace="alloy"}
```

```promql
alloy_resources_process_resident_memory_bytes{namespace="alloy"}
```

```promql
kube_pod_info{namespace="alloy"}
```

```promql
up{job="integrations/kubernetes/kube-state-metrics"}
```

**Pods without Alloy/Prometheus scrape `up` keyed by pod (tiles-test observation):**

- **`alloy-alloy-operator`** -- no matching `up{pod=~"alloy-alloy-operator.*"}` observed; kube-state-metrics still emits **`kube_pod_info`** et al. for this pod

**Kube-state-metrics and node-exporter** are ingested via **`integrations/kube-state-metrics`** and **`integrations/node_exporter`** rather than standalone `Probe` **`up`** lines under the same selectors as Alloy instances.

Adjust recording rules or relabel configs only after deciding whether operator/controller metrics deserve first-class Alloy scrape targets.

## Security

- Trust bundle mounted for SSL certificate validation (`trust-bundle` ConfigMap)
- Runs with privileged pod security policy (required for log collection and node metrics)

## Integrations block (values)

Chart **`integrations`** self-monitoring in `valuesObject` selects **`app.kubernetes.io/name` in `{alloy-metrics, alloy-singleton, alloy-logs, alloy-receiver}`** for the bundled **`integrations/alloy`** pipeline (plus **`metrics.tuning.includeMetrics`** for alloy-mixin metrics outside the default allow-list).

Additionally enabled: **cert-manager** integration scrape.

Additional integrations can be enabled via chart values as needed.

### Dashboards and rules (Tanka)

**Grafana alloy-mixin** is deployed as an Argo CD Application (**`alloy-mixin`**, tanka **`TK_ENV=alloy-mixin`**, namespace **`alloy`**), same pattern as other mixins. **`_config.filterSelector`** targets **`job="integrations/alloy"`** so panels align with the integration scrape path.

