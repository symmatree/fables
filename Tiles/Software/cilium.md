# Cilium

eBPF-based networking, security, and observability for Kubernetes. Deployed via in-repo Helm chart wrapping upstream Cilium.

## Configuration

- **Short summary**: Cilium CNI and Hubble; deploys from in-repo Helm chart (charts/cilium) wrapping upstream Cilium.
- **application.yaml type**: helm
- **Where loaded from**: In-repo path charts/cilium (Helm chart).
- **Version deployed**: main (repo targetRevision); chart dependency cilium 1.18.5
- **Links**:
  - Application: [application.yaml](https://github.com/symmatree/tiles/blob/main/charts/cilium/application.yaml)
  - values.yaml: [charts/cilium/values.yaml](https://github.com/symmatree/tiles/blob/main/charts/cilium/values.yaml)
- **If hosted in our repo**: Wraps upstream chart `cilium` 1.18.5 from https://helm.cilium.io/ (appVersion 1.18.5).
- **TF / bootstrap values**: Yes. Variables used: pod_cidr, cluster_name. No dedicated .tf; values from app-of-apps. TF: [k8s-cluster](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster).
- **Varies between prod and test**: Yes. Configuration varies by environment (pod_cidr, cluster_name, Hubble ingress hostname).

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*
