# Static Certs

Static Certificate resources (cluster-issued TLS for devices and services outside normal ingress). Deployed via in-repo Helm chart; Argo CD Application uses project `default`, not a Tiles-app-project. Each cluster that installs the argocd-applications bundle gets its own `static-certs` namespace and secrets -- use the kubeconfig for the cluster where you actually issue these certs.

## What the chart produces

Source: [`charts/static-certs`](https://github.com/symmatree/tiles/blob/main/charts/static-certs) (`values.yaml`, `templates/`).

cert-manager issues certificates via ClusterIssuer `real-cert` (Let's Encrypt, DNS01). Secrets live in namespace `static-certs`.

| Certificate `metadata.name` | DNS name(s) | Kubernetes secret | Notes |
|-----------------------------|-------------|-------------------|-------|
| raconteur | `raconteur.ad.local.symmatree.com` | `raconteur-cert` | Optional `.ad` subdomain in chart |
| morpheus | `morpheus.local.symmatree.com` | `morpheus-cert` | |
| homeassistant | `homeassistant.local.symmatree.com` | `homeassistant-cert` | |
| hubitat | `hubitat.local.symmatree.com` | `hubitat-cert` | |
| cam | `cam.local.symmatree.com` | `cam-cert` | Comment in chart: cam is hosted on raconteur |
| photos | `photos.local.symmatree.com` | `photos-cert` | |
| laserjet | `laserjet.local.symmatree.com` | `laserjet-cert` | Separate template; PKCS12 keystore; password from 1Password via OnePasswordItem |

Algorithm for all: ECDSA P-384, PKCS1, rotation policy Always. Standard entries use PEM `tls.crt` / `tls.key` in the secret. laserjet adds PKCS12 material for printer import (see chart template).

## Configuration (inventory)

- **Short summary**: Static Certificate resources; deploys from in-repo Helm chart (`charts/static-certs`).
- **application.yaml type**: helm
- **Where loaded from**: In-repo path `charts/static-certs`.
- **Version deployed**: main (`targetRevision` in Application spec)
- **Links**:
  - Application: [application.yaml](https://github.com/symmatree/tiles/blob/main/charts/static-certs/application.yaml)
  - Chart README (kubectl snippets, extract commands): [charts/static-certs/README.md](https://github.com/symmatree/tiles/blob/main/charts/static-certs/README.md)
  - values: [charts/static-certs/values.yaml](https://github.com/symmatree/tiles/blob/main/charts/static-certs/values.yaml)
- **TF / bootstrap values**: Yes. Variables used: `targetRevision` (in Application spec). No dedicated `.tf`; wired via app-of-apps. TF: [k8s-cluster](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster).
- **Varies between prod and test**: Yes. `targetRevision` may differ per deployment.

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*

---

## Rollout standardization (draft)

Goal: one predictable way to get TLS material from the cluster onto the hosts that need it, per certificate. Initial version is manual; automation can replace pieces later.

### Prerequisites

- kubectl access to the cluster where `static-certs` is synced and certificates are Ready.
- For Tiles clusters, prefer scoped kubeconfig via `KUBECONFIG` (see repo kubectl guidance).
- DNS: names must resolve and ACME DNS01 must succeed (external-dns, `real-cert`, etc.) -- see chart README for troubleshooting.

### Generic: confirm cert is ready

```bash
kubectl get certificates -n static-certs
kubectl describe certificate <name> -n static-certs
```

### Generic: extract PEM (standard certs)

Secret name pattern: `<name>-cert`. Keys: `tls.crt`, `tls.key`.

```bash
export NAME=morpheus
kubectl get secret -n static-certs "${NAME}-cert" -o jsonpath="{.data['tls\.crt']}" | base64 --decode > "${NAME}-cert.crt"
kubectl get secret -n static-certs "${NAME}-cert" -o jsonpath="{.data['tls\.key']}" | base64 --decode > "${NAME}-cert.key"
```

On macOS, use `base64 -D` or `base64 -d` instead of `base64 --decode` as appropriate.

Treat extracted files as secrets; avoid committing them; shred or delete local copies after install if policy requires.

### Generic: laserjet (PKCS12)

Uses `templates/laserjet.yaml`: password from 1Password item referenced by OnePasswordItem `laserjet-cert-password`. Inspect the issued secret for PKCS12 / keystore keys (chart README points at `templates/laserjet.yaml`). Rollout procedure stub below.

---

## Per-certificate rollout stubs

Fill in **Deploy target**, **Procedure**, and **Automation** as you decide each host's workflow.

### raconteur 

- **Certs:**
  - `raconteur.ad.local.symmatree.com`
  - `cam.local.symmatree.com`
  - `photos.local.symmatree.com`
- **Deploy target**: Synology DSM on raconteur (see [[Synology/Raconteur]], [[Devices/Raconteur]]).
- **Automation**: On tiles only (`values-prod.yaml`; off on tiles-test), daily [CronJob](https://github.com/symmatree/tiles/blob/main/charts/static-certs/templates/dsm-synology-cronjob.helm.yaml) in `static-certs` pushes `raconteur-cert`, `cam-cert`, and `photos-cert` via [acme.sh `synology_dsm` deploy](https://github.com/acmesh-official/acme.sh/blob/master/deploy/synology_dsm.sh) (see also [deploy hooks](https://github.com/acmesh-official/acme.sh/wiki/deployhooks)). Uses `raconteur-login` for DSM API credentials. Each FQDN must already exist as a DSM certificate with that description.

### morpheus (`morpheus.local.symmatree.com`)

- **Secret**: `morpheus-cert`
- **Deploy target**: TBD
- **Procedure**: TBD
- **Automation**: TBD

### homeassistant (`homeassistant.local.symmatree.com`)

- **Secret**: `homeassistant-cert`
- **Deploy target**: TBD
- **Procedure**: TBD
- **Automation**: TBD

### hubitat (`hubitat.local.symmatree.com`)

- **Secret**: `hubitat-cert`
- **Deploy target**: TBD (Hubitat hub UI / platform constraints)
- **Procedure**: TBD
- **Automation**: TBD

### laserjet (`laserjet.local.symmatree.com`)

- **Secret**: `laserjet-cert` (includes PKCS12 / keystore material for printer)
- **1Password**: item path `vaults/tiles-secrets/items/laserjet-cert-password` (see chart template)
- **Deploy target**: TBD (printer admin UI or USB import, etc.)
- **Procedure**: TBD
- **Automation**: TBD

---

## Related

- Chart documentation and troubleshooting: [charts/static-certs/README.md](https://github.com/symmatree/tiles/blob/main/charts/static-certs/README.md)
- Adding or removing a cert: edit `staticCerts` in chart `values.yaml` (and use `laserjet.yaml` pattern if PKCS12 or other special handling is needed)
