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

### raconteur (`raconteur.ad.local.symmatree.com`)

- **Secret**: `raconteur-cert`
- **Cluster**: Chart CRs / secrets for static-certs were observed on **tiles-test** (prod not checked here).
- **Deploy target**: **Synology DSM** on raconteur (RS1619xs+): HTTPS for DSM UI and services bound to that cert object (see [[Synology/Raconteur]], [[Devices/Raconteur]]). SAN is `raconteur.ad.local.symmatree.com`.

**Manual (UI):** DSM **Control Panel** > **Security** > **Certificate** -- import PEM + key from `raconteur-cert` (extract with generic commands, `NAME=raconteur`). Static-certs uses **ECDSA P-384**; if DSM rejects import, check DSM docs for imported-cert key types.

**DSM Web API (for automation):** Same overall shape as [acme.sh `deploy/synology_dsm.sh`](https://github.com/acmesh-official/acme.sh/blob/master/deploy/synology_dsm.sh).

- **Expired DSM TLS:** While DSM still presents an expired cert, strict HTTPS verification to `:5001` fails until you push a good cert -- use **`curl -k`** / **`verify=False`** only for those recovery calls.
- **Login:** `SYNO.API.Auth` with **`enable_syno_token=yes`** (get **`sid`** + **`synotoken`**). Every **`entry.cgi`** call after that needs header **`X-SYNO-TOKEN: <synotoken>`**; without it, **`SYNO.Core.Certificate.CRT` `list`** returned **119** in testing.
- **List certs:** **`POST`** `entry.cgi` with **`api=SYNO.Core.Certificate.CRT`**, **`method=list`**, **`version=1`**, **`_sid`** (not bare **`SYNO.Core.Certificate`** `list` via GET -- **103** here).
- **Import / replace slot:** **`POST`** `entry.cgi` **`api=SYNO.Core.Certificate`**, **`method=import`**, **`version=1`**, query **`_sid`** + **`SynoToken`**, header **`X-SYNO-TOKEN`**. Multipart files **`key`**, **`cert`**, **`inter_cert`**; form **`id`** (from list), **`desc`** (must match slot, e.g. `raconteur.ad.local.symmatree.com`); **`as_default=true`** if replacing the default slot. Split **`tls.crt`** into leaf + chain when multiple PEM certs are present.

**Terraform:** [synology-community/terraform-provider-synology](https://github.com/synology-community/terraform-provider-synology) **`synology_api`** only passes string parameters (query-style) -- **no multipart PEM upload**, so it does **not** replace DSM certificate import; use a script or Kubernetes Job instead.

**Reference implementation:** [acme.sh `deploy/synology_dsm.sh`](https://github.com/acmesh-official/acme.sh/blob/master/deploy/synology_dsm.sh). The Synology **upload** logic (login, list, multipart `import`) matches what you need, but the shell file is **not** a separable CLI: it sources acme.sh (`_post`, `_getdeployconf`, deployconf storage, temp-admin helpers). You cannot point it at arbitrary PEM files without either pulling in that framework or copying the **curl-style multipart POST** block into a thin wrapper. Feeding cert-manager output through acme.sh's on-disk layout under `~/.acme.sh/<domain>/` only to run `--deploy` is possible in theory but duplicates state and is brittle.

**Automation (Kubernetes):** Chart **`charts/static-certs`**: **`CronJob`** in namespace **`static-certs`** (enabled on prod via **`values-prod.yaml`**, off on test via **`values-test.yaml`**). Mounts selected **`tls`** Secrets and a **`OnePasswordItem`** for **`raconteur-login`** (DSM credentials). **`ConfigMap`** script clones **`acme.sh`**, builds per-domain **`~/.acme.sh/<fqdn>_ecc/`** layout from mounted PEMs (PKCS#12 split for leaf vs chain), runs **`--deploy --deploy-hook synology_dsm`**. Argo Application uses **`values-${targetRevision}.yaml`** alongside **`values.yaml`** (same **`targetRevision`** as misc-config: **`prod`** / **`test`**).

**Credentials:** [`tf/nodes/README.md`](https://github.com/symmatree/tiles/blob/main/tf/nodes/README.md) -- `op read op://tiles-secrets/raconteur-login/...` for local use; the CronJob uses keys **`username`** / **`password`** on the operator-synced Secret (adjust **`loginSecretKeys`** in chart values if the 1Password item uses different field names).

**Renewal:** cert-manager rotates the Secret on its schedule; DSM does **not** follow automatically -- re-import or run a sync when material changes.

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

### cam (`cam.local.symmatree.com`)

- **Secret**: `cam-cert`
- **Deploy target**: TBD (hosted on raconteur per chart comment)
- **Procedure**: TBD
- **Automation**: TBD

### photos (`photos.local.symmatree.com`)

- **Secret**: `photos-cert`
- **Deploy target**: TBD
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
