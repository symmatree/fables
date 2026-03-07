# external-dns

Kubernetes controller that configures external DNS providers (e.g. Google Cloud DNS) from Ingress and Service resources. Deployed via in-repo Helm chart.

## Configuration

- **Short summary**: external-dns for Google Cloud DNS; deploys from in-repo Helm chart (charts/external-dns) wrapping upstream external-dns.
- **application.yaml type**: helm
- **Where loaded from**: In-repo path charts/external-dns (Helm chart).
- **Version deployed**: main (repo targetRevision); chart dependency external-dns 1.19.0
- **Links**:
  - Application: [application.yaml](https://github.com/symmatree/tiles/blob/main/charts/external-dns/application.yaml)
  - values.yaml: [charts/external-dns/values.yaml](https://github.com/symmatree/tiles/blob/main/charts/external-dns/values.yaml)
  - TF: [external-dns.tf](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster/external-dns.tf)
- **If hosted in our repo**: Wraps upstream chart `external-dns` 1.19.0 from https://kubernetes-sigs.github.io/external-dns/ (appVersion 1.19.0).
- **TF / bootstrap values**: Yes. Variables used: cluster_name, project_id, vault_name. TF: [external-dns.tf](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster/external-dns.tf).
- **Varies between prod and test**: Yes. Configuration varies by environment (cluster_name, project_id, vault_name, domain filters).

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*
