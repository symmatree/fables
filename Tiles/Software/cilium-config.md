# Cilium Config

Cilium configuration objects (e.g. CiliumLoadBalancerIPPool, L2 announcements). Deployed via in-repo Helm chart; co-deployed with Cilium into the cilium namespace.

## Configuration

- **Short summary**: Cilium config resources (load balancer IP pools, L2); deploys from in-repo Helm chart (charts/cilium-config).
- **application.yaml type**: helm
- **Where loaded from**: In-repo path charts/cilium-config (Helm chart).
- **Version deployed**: main (repo targetRevision)
- **Links**:
  - Application: [application.yaml](https://github.com/symmatree/tiles/blob/main/charts/cilium-config/application.yaml)
  - (No values.yaml in repo for this chart; values in Application valuesObject.)
- **If hosted in our repo**: In-repo chart (no upstream dependency); appVersion 0.1.0.
- **TF / bootstrap values**: Yes. Variables used: external_ip_cidr, targetRevision. No dedicated .tf; values from app-of-apps. TF: [k8s-cluster](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster).
- **Varies between prod and test**: Yes. Configuration varies by environment (external_ip_cidr, targetRevision).

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*
