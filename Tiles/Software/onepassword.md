# 1Password Connect / Operator

1Password Connect server and Kubernetes operator for syncing secrets from 1Password into the cluster. Deployed via in-repo Helm chart.

## Configuration

- **Short summary**: 1Password Connect and Operator for syncing secrets from 1Password; deploys from in-repo Helm chart (charts/onepassword).
- **application.yaml type**: helm
- **Where loaded from**: In-repo path charts/onepassword (Helm chart).
- **Version deployed**: main (repo targetRevision); chart dependency connect 2.1.1
- **Links**:
  - Application: [application.yaml](https://github.com/symmatree/tiles/blob/main/charts/onepassword/application.yaml)
  - values.yaml: [charts/onepassword/values.yaml](https://github.com/symmatree/tiles/blob/main/charts/onepassword/values.yaml)
- **If hosted in our repo**: Wraps upstream chart `connect` 2.1.1 from https://1password.github.io/connect-helm-charts/ (appVersion 1.8.1).
- **TF / bootstrap values**: No.
- **Varies between prod and test**: No.

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*
