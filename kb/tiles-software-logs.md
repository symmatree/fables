# Tiles Software Logs

How to get logs for a single Tiles software component: via **Grafana (Loki)** for aggregated log queries, or via **kubectl** for live pod logs. Each `Tiles/Software/<component>.md` doc can include a **Logs** section with component-specific commands and an optional short summary of the trailing ~50 lines (collected when the process is run).

## Prerequisites

- **Grafana**: Access to Grafana (e.g. `https://borgmon.{cluster_name}.symmatree.com`). Use the Loki datasource for log queries.
- **kubectl**: Kubeconfig for the cluster (e.g. from 1Password; see tiles repo `docs/dev-setup.md`). Commands below assume your current context is the target cluster.

## 1. Querying logs in Grafana (Loki)

Logs from the cluster are collected by Alloy and stored in Loki. You can query them in Grafana:

1. Open **Grafana → Explore**.
2. Select the **Loki** datasource.
3. Use **LogQL** to filter by namespace and/or labels.

### LogQL for a single component

- **All logs from a namespace** (typical starting point for one component):
  ```logql
  {namespace="cert-manager"}
  ```
- **Logs from a specific app within the namespace** (when the component has multiple deployments, e.g. cert-manager, webhook, cainjector, trust-manager):
  ```logql
  {namespace="cert-manager", app_kubernetes_io_name="cert-manager"}
  ```
- **Narrow by time range**: Use the time picker (top right). Default is usually last hour.

### Useful LogQL patterns

| Goal | LogQL example |
|------|----------------|
| One namespace | `{namespace="<namespace>"}` |
| One namespace, one app label | `{namespace="<namespace>", app_kubernetes_io_name="<name>"}` |
| Include only lines containing text | `{namespace="cert-manager"} \|= "error"` |
| Exclude lines | `{namespace="cert-manager"} != "debug"` |
| Last 100 lines (approx.) | Same query; use "Limit" in the query options or scroll. |

Replace `<namespace>` with the component's namespace (e.g. `cert-manager`, `grafana`, `loki`). Replace `<name>` with the value of the `app.kubernetes.io/name` label (often the same as the component name, or a sub-component like `webhook`, `cainjector`).

## 2. Getting logs with kubectl

For **live** logs from a specific pod or set of pods (e.g. to debug right now, or to capture a "trailing 50 lines" snapshot):

### One-liner template

```bash
kubectl logs -n <namespace> -l app.kubernetes.io/name=<name> --tail=50
```

- **`<namespace>`**: Kubernetes namespace (e.g. `cert-manager`, `grafana`). Matches the component's Application `destination.namespace` in the tiles repo.
- **`<name>`**: Label value for `app.kubernetes.io/name` on the pod(s) you care about. For a single-deployment component this is usually the component name; for multi-workload components (e.g. cert-manager) there may be several names (e.g. `cert-manager`, `webhook`, `cainjector`, `trust-manager`).

### Options

- **`--tail=50`**: Last 50 lines (adjust as needed). Omit for full log stream.
- **`-f`**: Follow (stream) logs.
- **`--all-containers=true`**: If a pod has multiple containers and you want all of them (default is first container only).
- **`--prefix=true`**: Prefix each line with pod name (useful when multiple pods match the label).

### When there are multiple workloads in one namespace

Run one command per workload and keep outputs separate (or label the sections). Example for cert-manager:

```bash
# Controller
kubectl logs -n cert-manager -l app.kubernetes.io/name=cert-manager --tail=50

# Webhook
kubectl logs -n cert-manager -l app.kubernetes.io/name=webhook --tail=50

# CA injector
kubectl logs -n cert-manager -l app.kubernetes.io/name=cainjector --tail=50

# Trust manager
kubectl logs -n cert-manager -l app.kubernetes.io/name=trust-manager --tail=50
```

## 3. Per-component Logs section in Tiles/Software

Each `Tiles/Software/<component>.md` file can have a **Logs** section that:

1. **Grafana/Loki**: Gives the LogQL to use for that component (namespace and optional label).
2. **kubectl**: Gives the exact `kubectl logs` command(s) for that component (namespace, label, and any `--tail` or other flags).
3. **Trailing lines summary** (optional): A short prose summary of what the last ~50 lines typically show (e.g. "Controller idle, no renewals; webhook serving; no errors"). This is filled in when someone runs the commands during the logs collection process.

Style: same as other data-collection footnotes—e.g. "Logs section updated by tiles-software-logs on YYYY-MM-DD. See [[tiles-software-logs]] for how to run queries and kubectl commands."

**Do not update user-written content.** Only add or replace the **Logs** section and its footnote. Do not edit, "fix," or rewrite any other content in the file (e.g. Configuration, Overview, Architecture). Preserve it exactly.

## 4. Running the logs collection (one component at a time)

1. Choose a component (e.g. cert-manager).
2. Open its `Tiles/Software/<component>.md` and find or add the **Logs** section.
3. Run the documented **kubectl** command(s) (and optionally the Grafana query) against the target cluster.
4. If you are maintaining the "trailing 50 lines" summary: review the output and add or update a short summary in the Logs section.
5. Add or update the footnote with the current date and link to this doc.

No need to re-run for every component in one go; the typical case is one component at a time.

## Questions / open points

- **Cluster access**: Log commands were not run from this environment (no network to the API server). If you run them (e.g. for cert-manager), we can confirm the namespace and labels match and adjust the central doc or component examples if needed.
- **Summary format**: Prefer a single short paragraph per workload, or a bullet list? Any standard wording (e.g. "No errors in trailing 50 lines") you want to use when there's nothing notable?
- **Which components get a Logs section first**: We can roll out Logs sections (and remove generic Troubleshooting/Logs blocks) component by component; cert-manager is the first example.
