# cert-manager

Certificate management for Kubernetes; issues and renews TLS certificates. Deployed via in-repo Helm chart wrapping cert-manager and trust-manager.

## Configuration

- **Short summary**: cert-manager and trust-manager for TLS and CA; deploys from in-repo Helm chart (charts/cert-manager).
- **application.yaml type**: helm
- **Where loaded from**: In-repo path charts/cert-manager (Helm chart).
- **Version deployed**: main (repo targetRevision); dependencies cert-manager 1.19.2, trust-manager 0.20.3
- **Links**:
  - Application: [application.yaml](https://github.com/symmatree/tiles/blob/main/charts/cert-manager/application.yaml)
  - values.yaml: [charts/cert-manager/values.yaml](https://github.com/symmatree/tiles/blob/main/charts/cert-manager/values.yaml)
  - TF: [k8s-cert-manager.tf](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster/k8s-cert-manager.tf)
- **If hosted in our repo**: Wraps upstream charts cert-manager 1.19.2 and trust-manager 0.20.3 from https://charts.jetstack.io.
- **TF / bootstrap values**: Yes. Variables used: cluster_name, project_id, seed_project_id, vault_name. TF: [k8s-cert-manager.tf](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster/k8s-cert-manager.tf).
- **Varies between prod and test**: Yes. Configuration varies by environment (cluster_name, project_id, seed_project_id, vault_name).

*Configuration section updated by tiles-software-data-collection on 2026-02-15. See [[tiles-software-data-collection]] for update instructions.*

## Logs

- **Grafana (Loki)**  
  - All cert-manager logs: `{namespace="cert-manager"}`  
  - Controller only: `{namespace="cert-manager", app_kubernetes_io_name="cert-manager"}`  
  - Webhook: `{namespace="cert-manager", app_kubernetes_io_name="webhook"}`  
  - CA injector: `{namespace="cert-manager", app_kubernetes_io_name="cainjector"}`  
  - Trust manager: `{namespace="cert-manager", app_kubernetes_io_name="trust-manager"}`  
  See [[tiles-software-logs]] for how to run queries in Grafana.

- **kubectl** (trailing 50 lines; run against the target cluster):
  ```bash
  kubectl logs -n cert-manager -l app.kubernetes.io/name=cert-manager --tail=50
  kubectl logs -n cert-manager -l app.kubernetes.io/name=webhook --tail=50
  kubectl logs -n cert-manager -l app.kubernetes.io/name=cainjector --tail=50
  kubectl logs -n cert-manager -l app.kubernetes.io/name=trust-manager --tail=50
  ```

- **Trailing 50 lines summary** (collected 2026-02-16):
  - **Controller**: Startup from 2026-02-13: controllers and caches coming up; several info-level "owning resource not found in cache" for Order CRs (alloy, apprise, argocd, cilium, grafana, odm, static-certs) during cache warmup. A burst of "re-queuing item due to error processing" with "ACME client for issuer not initialised/available" from startup before ACME was ready, then "ACME server URL host and ACME private key registration host differ. Re-checking ACME account registration" for real-cert and staging-cert, then "verified existing registration with ACME server" for both. So: startup noise and ACME verification; the "ACME client not initialised" and "owning resource not found" lines are expected at/cache warmup.
  - **Webhook**: Startup from 2026-01-31: version, feature gates, one "Failed to generate serving certificate, retrying..." then CA and TLS cert in place. Recurring "cert-manager webhook certificate requires renewal, regenerating" and "Updated cert-manager TLS certificate" on Feb 5, 10, 13, 14—routine renewal. No ongoing errors.
  - **CA injector**: Last 50 lines are mostly "unable to fetch certificate that owns the secret" / "Certificate ... not found" for secrets in `cilium-secrets` (apprise-tls, hubble-ui-tls, grafana-tls, argocd-server-tls, webodm-tls, otlp-tls). The Certificate CRs live in the app namespaces; cainjector sees the copied secrets in cilium-secrets and logs when it can't find a Certificate there. A few "Updated object" lines for webhook configs. So: these "Certificate not found" messages are expected for the cilium-secrets copy pattern; they have been present on collection and are not by themselves a sign of a new failure.
  - **Trust-manager**: Startup from 2026-02-13: package load, webhook registration, server and leader election, EventSources and Controller started. One past ERROR: "Failed to update lock optimistically... Client.Timeout exceeded... falling back to slow path" during a lease renewal—transient API timeout, not ongoing.

**Why the CA injector logs "Certificate not found" for cilium-secrets:**  
The CA injector provides CA data for **webhook** and **CRD** `caBundle` fields (so the API server can verify webhook TLS), not for regular pods. It is driven by metadata: Secrets carrying an annotation like `cert-manager.io/certificate-name` are treated as certificate-backed, and the injector looks up the referenced Certificate in the **same namespace** to prepare injection. Cilium copies TLS secrets into **cilium-secrets** for ingress, including that ownership annotation, but the **Certificate** resources stay in the app namespaces. So the injector sees the copied secrets, looks for the Certificate in cilium-secrets, doesn't find it, and logs—expected. Cert-manager has no option to restrict or ignore namespaces, so this log noise is normal.

*Logs section follows [[tiles-software-logs]]. Update the trailing-lines summary when running the process.*
