# Mimir

## Interesting points

This is pretty stock, but a few decisions:

* Tenanted, though so far using a single tenant; expecting to have external resources pushing at some point.
* Uses Mimir AlertManager for metrics-based alerting, not just Grafana. This is based on a comment from one of
  the Grafana devs on a bug stating that they would absolutely recommend this setup and only using Grafana
  alerting for combining multiple data sources or other fanciness that only it can do.
* Does not do its own scraping, expects to have metrics pushed to it from Alloy.
* Gets Rules pushed to it by Alloy; evaluates and sends alerts.
* Notifications go through a sidecar pod that accepts a webhook call and formats it to push to AppRise.

## Configuration

- **Short summary**: Mimir distributed metrics storage and alerting; deployed via Helm from Grafana helm-charts repo, receives metrics from Alloy and uses Alertmanager with AppRise for notifications.
- **application.yaml type**: helm
- **Where loaded from**: Helm chart `mimir-distributed` from https://grafana.github.io/helm-charts
- **Version deployed**: 6.0.5
- **Links**:
  - Application: [mimir-application.yaml](https://github.com/symmatree/tiles/blob/main/charts/argocd-applications/templates/mimir-application.yaml)
  - (No values.yaml in repo; values in Application valuesObject.)
- **TF / bootstrap values**: Yes. Variables used: cluster_name, vault_name, nfs_server, cluster_nfs_path. No dedicated .tf; values from app-of-apps. TF: [k8s-cluster](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster).
- **Varies between prod and test**: Yes. Configuration varies by environment (cluster_name, vault_name, nfs_server, cluster_nfs_path, ingress hostname).

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*

## Configuration Design

* **Tenant Limits**: The `max_rules_per_rule_group` limit is set to 50 to accommodate rule groups with up to 50 rules per group. This was increased from the default of 20 to support actual workload requirements (observed: 26 rules) with headroom for future growth.
