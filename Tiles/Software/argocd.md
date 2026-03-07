# Argo CD

GitOps continuous delivery tool for Kubernetes. Deployed via in-repo Helm chart wrapping the upstream argo-cd chart.

## Configuration

- **Short summary**: Argo CD for GitOps; deploys from in-repo Helm chart (charts/argocd) wrapping upstream argo-cd.
- **application.yaml type**: helm
- **Where loaded from**: In-repo path charts/argocd (Helm chart).
- **Version deployed**: main (repo targetRevision); chart dependency argo-cd 9.2.3
- **Links**:
  - Application: [application.yaml](https://github.com/symmatree/tiles/blob/main/charts/argocd/application.yaml)
  - values.yaml: [charts/argocd/values.yaml](https://github.com/symmatree/tiles/blob/main/charts/argocd/values.yaml)
- **If hosted in our repo**: Wraps upstream chart `argo-cd` 9.2.3 from https://argoproj.github.io/argo-helm (appVersion 3.2.3).
- **TF / bootstrap values**: Yes. Variables used: targetRevision, cluster_name, vault_name. No dedicated .tf; values from app-of-apps. TF: [k8s-cluster](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster).
- **Varies between prod and test**: Yes. Configuration varies by environment (targetRevision, cluster_name, vault_name, domain hostnames).

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*
