# Grafana

## Overview

[Grafana](https://github.com/grafana/grafana) is a visualization and analytics platform for metrics and logs, providing dashboards and alerting capabilities for the LGTM (Loki/Grafana/Tempo/Mimir) observability stack. It serves as the central visualization layer for cluster monitoring and observability.

Grafana is deployed using the [Grafana Helm chart](https://github.com/grafana/helm-charts) and automatically discovers dashboards and datasources from Kubernetes ConfigMaps across all namespaces.

## Architecture

Grafana is deployed as a single instance with the following features:

- **Dashboard Sidecar**: Automatically discovers and loads dashboards from ConfigMaps with `grafana_dashboard: "1"` label across all namespaces
- **Datasource Sidecar**: Automatically discovers and configures datasources from ConfigMaps with `grafana_datasource: "1"` label across all namespaces
- **Persistence**: Enabled - Grafana configuration and dashboards are persisted to a PVC
- **Plugins**: Installed plugins for GitHub datasource and Loki explore

### Dashboard Discovery

Dashboards are automatically discovered from ConfigMaps with:

- Label: `grafana_dashboard: "1"`
- Annotation: `k8s-sidecar-target-directory` (specifies folder path)
- Searches all namespaces (`searchNamespace: ALL`)

Dashboards are organized into folders based on the `k8s-sidecar-target-directory` annotation, allowing mixins to organize dashboards by component.

### Datasource Discovery

Datasources are automatically discovered from ConfigMaps with:

- Label: `grafana_datasource: "1"`
- Searches all namespaces (`searchNamespace: ALL`)

Common datasources include:

- **Mimir**: Metrics storage backend
- **Loki**: Log aggregation system
- **AlertManager**: Alert management
- **GitHub**: GitHub API datasource (via plugin)

## Configuration

- **Short summary**: Grafana visualization and analytics platform for the LGTM stack; deploys via Helm from Grafana helm-charts repo, discovers dashboards and datasources from ConfigMaps.
- **application.yaml type**: helm
- **Where loaded from**: Helm chart `grafana` from https://grafana.github.io/helm-charts
- **Version deployed**: 10.4.2
- **Links**:
  - Application: [grafana-application.yaml](https://github.com/symmatree/tiles/blob/main/charts/argocd-applications/templates/grafana-application.yaml)
  - (No values.yaml in repo; values in Application valuesObject.)
- **TF / bootstrap values**: Yes. Variables used: cluster_name, vault_name. No dedicated .tf; values from app-of-apps. TF: [k8s-cluster](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster).
- **Varies between prod and test**: Yes. Configuration varies by environment (cluster_name, vault_name, ingress hostname).

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*

## Configuration Design

Configuration is managed through the Application's `valuesObject`:

- **Ingress Host**: `borgmon.{cluster_name}.symmatree.com`
- **TLS**: Managed by cert-manager using `real-cert` ClusterIssuer
- **Persistence**: Enabled - Stores Grafana configuration and dashboards
- **Admin User**: Loaded from 1Password `grafana-admin-user` item
- **Plugins**: `grafana-github-datasource`, `grafana-lokiexplore-app`
- **Trust Bundle**: Mounts cluster CA certificate for internal service authentication

### Environment-Specific Settings

- Cluster name and vault name are cluster-specific and set via Terraform/bootstrap process
- Ingress hostname is cluster-specific

### Dependencies

- **[[cert-manager]]**: Required for TLS certificate management
- **[[external-dns]]**: Required for DNS record creation
- **[[onepassword]]**: Required for syncing admin credentials and GitHub token
- **[[mimir]]**: Metrics datasource (auto-discovered)
- **[[loki]]**: Logs datasource (auto-discovered)
- **Mixins**: Provide dashboards and alerts (ArgoCD, Cilium, Kubernetes, Node Exporter)

## Prerequisites

### Required Secrets

- **Admin User**: Stored in 1Password as `grafana-admin-user`
  - Synced to Kubernetes via OnePasswordItem CRD
  - Contains `username` and `password` keys
- **GitHub Token**: Stored in 1Password as `grafana-github-token`
  - Synced to Kubernetes via OnePasswordItem CRD
  - Used for GitHub datasource plugin

### Required Infrastructure

- **DNS Zone**: `{cluster_name}.symmatree.com` must be managed by external-dns
- **TLS Certificate**: Managed by cert-manager

## Terraform Integration

No dedicated .tf; bootstrap values come from the app-of-apps (see **Configuration** above).

## Application Manifest

See **Configuration** above for Application link, chart version, and namespace.

## Access & Endpoints

### Web UI

- **URL**: `https://borgmon.{cluster_name}.symmatree.com`
- **Authentication**: Admin user (credentials from 1Password `grafana-admin-user` item)
- **TLS**: Managed by cert-manager

## Monitoring & Observability

### Metrics

- Grafana exposes its own metrics (can be scraped by Alloy/Mimir)
- TODO: Document if Grafana has a ServiceMonitor

### Dashboards

Grafana automatically discovers dashboards from mixins:

- **[[argocd-mixin]]**: Application and operational dashboards (see [[argocd]] for deployment)
- **[[cilium-mixin]]**: Network and Hubble dashboards (see [[cilium]] for deployment)
- **[[kubernetes-mixin]]**: Cluster and node dashboards covering cluster health, resource usage, API server, controller manager, and scheduler metrics
- **[[node-exporter-mixin]]**: Node-level metrics dashboards covering CPU, memory, disk, network, and system metrics

Dashboards are organized into folders based on the `k8s-sidecar-target-directory` annotation.

### Alerts

- Grafana alerting is configured to route to Mimir's AlertManager
- Alerts are defined by mixins:
  - **[[argocd-mixin]]**: Application sync failures, health issues, component failures
  - **[[cilium-mixin]]**: Network and Hubble-related alerts
  - **[[kubernetes-mixin]]**: Node failures, pod evictions, resource exhaustion, component health issues
  - **[[node-exporter-mixin]]**: High CPU usage, memory pressure, disk space exhaustion, network issues

### Logs

View Grafana logs:

```bash
# View Grafana pod logs
kubectl logs -n grafana -l app.kubernetes.io/name=grafana
```

## Troubleshooting

### Common Issues

**Grafana not accessible:**

- Verify ingress is created: `kubectl get ingress -n grafana`
- Check certificate status: `kubectl get certificate -n grafana`
- Verify external-dns created DNS record
- Check Grafana pod is running: `kubectl get pods -n grafana`

**Dashboards not appearing:**

- Verify dashboard ConfigMaps exist with `grafana_dashboard: "1"` label
- Check dashboard ConfigMap has `k8s-sidecar-target-directory` annotation
- Verify sidecar is running: Check Grafana pod logs for sidecar errors
- Check Grafana UI → Dashboards → Browse to see discovered dashboards

**Datasources not appearing:**

- Verify datasource ConfigMaps exist with `grafana_datasource: "1"` label
- Check datasource ConfigMaps are in correct format
- Verify sidecar is running: Check Grafana pod logs for sidecar errors
- Check Grafana UI → Connections → Data sources to see discovered datasources

**Authentication failures:**

- Verify admin user secret exists: `kubectl get secret grafana-admin-user -n grafana`
- Check secret has `username` and `password` keys
- Verify OnePasswordItem is synced: `kubectl get onepassworditem grafana-admin-user -n grafana`

**Plugin errors:**

- Verify plugins are installed: Check Grafana pod logs for plugin loading errors
- Check plugin compatibility with Grafana version
- Restart Grafana pod if plugins fail to load

### Health Checks

- Verify Grafana pod is running: `kubectl get pods -n grafana`
- Check Application is synced: `kubectl get application grafana -n argocd`
- Test web UI access: Navigate to `https://borgmon.{cluster_name}.symmatree.com`
- Verify datasources: Check Grafana UI → Connections → Data sources

## Maintenance

### Update Procedures

- Update the `targetRevision` in `grafana-application.yaml` to the desired chart version
- ArgoCD will automatically sync the changes
- Note: Grafana updates may require pod restarts and may cause brief downtime

### Backup Requirements

- **Dashboards**: Most dashboards are generated from mixins and can be recreated
- **Admin Credentials**: Stored in 1Password, backed up there
- **GitHub Token**: Stored in 1Password, backed up there
- **PVC**: Used for transient dashboard edits and quick dashboards without PRs - no backup needed

### Known Limitations

- **Single Instance**: Grafana runs as a single instance (no HA)

## Usage

### Accessing Grafana

1. Navigate to `https://borgmon.{cluster_name}.symmatree.com`
2. Log in with admin credentials from 1Password `grafana-admin-user` item
3. Browse dashboards from the Dashboards menu
4. Explore logs using the Explore feature (Loki datasource)
5. View metrics using the Explore feature (Mimir datasource)

### Adding Dashboards

Dashboards are automatically discovered from ConfigMaps. To add a new dashboard:

1. Create a ConfigMap with:
   - Label: `grafana_dashboard: "1"`
   - Annotation: `k8s-sidecar-target-directory: /tmp/dashboards/{folder}`
   - Data: Dashboard JSON in a key (typically the dashboard name)

2. The sidecar will automatically discover and load the dashboard

### Adding Datasources

Datasources are automatically discovered from ConfigMaps. To add a new datasource:

1. Create a ConfigMap with:
   - Label: `grafana_datasource: "1"`
   - Data: Datasource YAML in `datasource.yaml` key

2. The sidecar will automatically discover and configure the datasource

### Trust Bundle

Grafana mounts the cluster CA certificate (`trust-bundle` ConfigMap) to enable TLS verification for internal services. This allows Grafana to connect to Mimir, Loki, and other internal services using TLS with the cluster's self-signed CA.
