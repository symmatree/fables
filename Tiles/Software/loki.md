# Loki

## Overview

[Loki](https://github.com/grafana/loki) is a horizontally scalable log aggregation system that collects, stores, and queries logs from cluster components. It provides centralized log storage and querying capabilities as part of the LGTM (Loki/Grafana/Tempo/Mimir) observability stack.

Loki is deployed using the [Loki Helm chart](https://github.com/grafana/helm-charts) in single binary mode with on-premises NFS storage for log data persistence.

## Architecture

Loki is deployed in **single binary mode** (`deploymentMode: SingleBinary`), which runs all Loki components in a single pod:

- **Single Binary**: All Loki components (ingester, querier, distributor, etc.) run in one process
- **Replicas**: 1 (single instance)
- **Storage**: On-premises NFS via static PV with fixed path
- **Schema**: TSDB with filesystem storage backend

### Storage Architecture

Loki uses a hybrid storage approach:

- **Local Path Storage**: Used for the single binary pod's local persistence (StatefulSet PVC)
- **NFS Storage**: Used for actual log data storage (chunks and rules directories)
  - Static PV with fixed path: `/volume2/{cluster_name}/loki-data`
  - Mounted at `/mnt/loki-nfs` in the pod
  - Chunks stored in `/mnt/loki-nfs/chunks`
  - Rules stored in `/mnt/loki-nfs/rules`

See [`docs/nfs-storage-architecture.md`](../../../docs/nfs-storage-architecture.md) for detailed information on the NFS storage strategy.

### Multi-tenancy

Loki is configured with multi-tenancy support:

- **Auth Enabled**: `false` (no authentication, but multi-tenancy headers are used)
- **Tenant ID**: Cluster name (passed via `X-Scope-OrgID` header)
- **Grafana Integration**: Uses cluster name as tenant ID in datasource configuration

## Configuration

- **Short summary**: Loki log aggregation system in single-binary mode with NFS storage; deployed via Helm from Grafana helm-charts repo.
- **application.yaml type**: helm
- **Where loaded from**: Helm chart `loki` from https://grafana.github.io/helm-charts
- **Version deployed**: 6.49.0
- **Links**:
  - Application: [loki-application.yaml](https://github.com/symmatree/tiles/blob/main/charts/argocd-applications/templates/loki-application.yaml)
  - (No values.yaml in repo; values in Application valuesObject.)
- **TF / bootstrap values**: Yes. Variables used: cluster_name, vault_name, nfs_server, cluster_nfs_path. No dedicated .tf; values from app-of-apps. TF: [k8s-cluster](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster).
- **Varies between prod and test**: Yes. Configuration varies by environment (cluster_name, vault_name, nfs_server, cluster_nfs_path).

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*

## Configuration Design

Configuration is managed through the Application's `valuesObject`:

- **Deployment Mode**: `SingleBinary` - All components in one pod
- **Storage Type**: `filesystem` - Uses NFS-mounted filesystem
- **Schema**: TSDB v13 (from 2024-04-01)
- **Replication Factor**: 1 (single instance)
- **Chunk Encoding**: Snappy compression
- **Pattern Ingester**: Enabled - Pattern-based log ingestion
- **Volume Enabled**: Enabled - Volume-based storage
- **Tracing**: Enabled - Distributed tracing support
- **Ruler API**: Enabled - Log alerting rules API

### Storage Configuration

- **Chunks Directory**: `/mnt/loki-nfs/chunks` - Log chunk storage
- **Rules Directory**: `/mnt/loki-nfs/rules` - Alerting rules storage
- **NFS Path**: `{cluster_nfs_path}/loki-data` (e.g., `/volume2/tiles/loki-data`)
- **PV Size**: 100Gi
- **Access Mode**: ReadWriteMany (RWX) - Required for shared access

### Environment-Specific Settings

- Cluster name, NFS server, and NFS path are cluster-specific and set via Terraform/bootstrap process
- NFS path is stored in 1Password `{cluster_name}-misc-config` secret

### Dependencies

- **[[nfs-csi-driver]]**: Required for NFS storage (though this uses static PV, not dynamic provisioning)
- **[[local-path-provisioner]]**: Used for single binary pod's local persistence
- **[[grafana]]**: Visualization and query interface for logs
- **[[alloy]]**: Scrapes logs from cluster components and forwards to Loki

## Prerequisites

### Required Infrastructure

- **NFS Share**: `{cluster_nfs_path}/loki-data` must exist on the NFS server
  - Created automatically by Loki or must be pre-created
  - See [`docs/nfs-storage-architecture.md`](../../../docs/nfs-storage-architecture.md) for setup details

## Terraform Integration

No dedicated .tf; bootstrap values from app-of-apps (see **Configuration** above). Storage was previously managed via GCP buckets with Terraform-managed service accounts, but has been migrated to on-premises NFS.

## Application Manifest

See **Configuration** above for Application link, chart version, and namespace.

## Access & Endpoints

### Internal Service

- **Service**: `loki.loki.svc:3100` - Internal Loki API endpoint
- **Grafana Datasource**: Automatically configured via ConfigMap with `grafana_datasource: "1"` label
- **Tenant ID**: Cluster name (passed via `X-Scope-OrgID` header)

### External Access

Loki is accessed via Grafana's Explore feature. There is no external ingress for direct Loki access.

## Monitoring & Observability

### Metrics

- **Prometheus ServiceMonitor**: Enabled - Loki exposes Prometheus metrics
- Metrics endpoint: Available on Loki service

### Dashboards

- **Loki Dashboards**: Disabled in Helm chart (dashboards provided by mixins if needed)
- **Grafana Integration**: Logs are queried via Grafana's Explore feature

### Alerts

- **Loki Rules**: Disabled in Helm chart (alerts managed by other components)
- **Ruler API**: Enabled - Can be used to manage log alerting rules

### Logs

View Loki logs:

```bash
# View single binary pod logs
kubectl logs -n loki -l app.kubernetes.io/name=loki
```

## Troubleshooting

### Common Issues

**Loki pod not starting:**

- Verify NFS PV exists: `kubectl get pv loki-loki-data`
- Check PVC is bound: `kubectl get pvc loki-loki-data -n loki`
- Verify NFS server is accessible: Test NFS mount manually
- Check Loki pod logs for errors (see Logs section above)

**Logs not being ingested:**

- Verify Alloy is running and configured to scrape logs: `kubectl get pods -n alloy`
- Check Alloy configuration for Loki endpoint
- Verify Loki service is accessible: `kubectl get svc loki -n loki`
- Check Loki pod logs for ingestion errors

**Storage issues:**

- Verify NFS PV is mounted: `kubectl exec -n loki <pod> -- ls -la /mnt/loki-nfs`
- Check NFS server connectivity and permissions
- Verify storage paths exist: Check `/mnt/loki-nfs/chunks` and `/mnt/loki-nfs/rules`
- Review NFS storage architecture doc for setup requirements

**Query performance issues:**

- Check querier `max_concurrent` setting (default: 4)
- Monitor Loki pod resource usage: `kubectl top pod -n loki`
- Review query patterns and optimize LogQL queries
- Consider increasing resources if needed

**Grafana datasource not working:**

- Verify datasource ConfigMap exists: `kubectl get configmap loki-data-source -n loki`
- Check datasource configuration in Grafana UI
- Verify tenant ID matches cluster name
- Check Loki service is accessible from Grafana

### Health Checks

- Verify Loki pod is running: `kubectl get pods -n loki`
- Check PV and PVC are bound: `kubectl get pv,pvc -n loki`
- Verify Application is synced: `kubectl get application loki -n argocd`
- Test log query via Grafana Explore feature

## Maintenance

### Update Procedures

- Update the `targetRevision` in `loki-application.yaml` to the desired chart version
- ArgoCD will automatically sync the changes
- Note: Loki updates may require pod restarts and brief downtime

### Backup Requirements

- **Log Data**: Stored on NFS, backed up at NAS level
- **Configuration**: Stored in Git (application.yaml), backed up there
- **Static PV**: Persists independently, survives Application deletion

### Known Limitations

- **Single Instance**: Loki runs as a single instance (no HA)
- **Single Binary Mode**: All components in one pod (simpler but less scalable)
- **NFS Dependency**: Log storage depends on NFS server availability

## Usage

### Querying Logs

Logs are queried via Grafana's Explore feature:

1. Navigate to Grafana → Explore
2. Select "Loki" datasource
3. Enter LogQL query (e.g., `{namespace="argocd"}`)
4. View logs in table or graph format

### LogQL Examples

- **All logs from a namespace**: `{namespace="argocd"}`
- **Logs with specific label**: `{app="argocd-repo-server"}`
- **Filter by log level**: `{namespace="argocd"} |= "error"`
- **Rate queries**: `rate({namespace="argocd"}[5m])`

### Storage Management

Log data is stored on NFS at `/volume2/{cluster_name}/loki-data`. Storage is managed by Loki's retention policies and compaction. Monitor disk usage on the NFS server to ensure adequate space.

See [`docs/nfs-storage-architecture.md`](../../../docs/nfs-storage-architecture.md) for detailed information on NFS storage setup and management.
