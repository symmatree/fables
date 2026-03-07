# Tiles Software Data Collection Process

## Overview

This document describes the process for collecting and maintaining a **Configuration** section in the facts knowledge base for each piece of software deployed in the Tiles Kubernetes cluster. The source of truth is the **tiles** GitOps repository (symmatree/tiles): ArgoCD Application manifests, Helm charts, Terraform under `tf/modules/k8s-cluster`, and Tanka/Jsonnet under `tanka/environments`. Output files live in `Tiles/Software/` (one file per component, e.g. `nfs-csi-driver.md`, `grafana.md`). The procedure also updates the **Tiles/Software** section in `kb/things.md` with a list of links to those files.

**When following this process:** Use the actual current date whenever the procedure calls for a date (e.g. collection-date footnote). Do not invent steps or data—if the tiles repo structure or a manifest doesn't match what is described here, stop and ask the user rather than guessing. Only add or replace the `## Configuration` section in each file; preserve all other content. **Do not update user-written content:** do not edit, "fix," or rewrite any content outside the Configuration section (e.g. Overview, Architecture, notes). Only replace the `## Configuration` block and its footnote.

Please execute this procedure carefully, noting any concerns or ambiguities. If anything doesn't work, please stop to consult rather than inventing a new procedure. Similarly if you have better ideas, please make a list of suggestions. This is still a new process, we expect
to have improvements and simply things we got wrong, please help us find them and make this
stable and repeatable.

## Prerequisites

- **Tiles repo**: The repository must be available locally (clone of https://github.com/symmatree/tiles or a path provided by the user). No API keys are required; all data comes from the repo files.
- **Facts repo**: You are working inside the facts repository. Output goes under `Tiles/Software/` and `kb/things.md`.
- **Docs**: Documentation about the Kubernetes deployment and GitOps can be found in the docs directory under the Tiles repo.

## Data Collection Method

### 1. Discover Application manifests

- **Templates**: List all `*-application.yaml` files in `charts/argocd-applications/templates/` (these are ArgoCD Application manifests, possibly Helm-templated).
- **In-repo charts**: Some components are deployed via an `application.yaml` that lives next to the chart (e.g. `charts/argocd/application.yaml`, `charts/cert-manager/application.yaml`). Those are often symlinked into `argocd-applications/templates/`. Discover them by scanning `charts/*/application.yaml` and/or the templates directory; dedupe by Application `metadata.name`.
- **Root**: The app-of-apps is defined by `charts/argocd-applications/application.yaml.tmpl` (or equivalent) and its values; you may need this to understand bootstrap variables. Treat it as a first-class source.

For each Application resource (from templates or from chart application.yaml):

- Read `metadata.name` → component name (e.g. `nfs-csi-driver`, `grafana`, `apprise`).
- Read `spec.source`:
  - If `chart` and `repoURL` are set: type is **helm**; note `repoURL`, `targetRevision`, `chart`.
  - If `path` is set: you must **inspect that path** in the repo:
    - If the path contains a file `Chart.yaml` → type **helm**; note path, read Chart.yaml for dependencies/appVersion.
    - If the path is `tanka` or under `tanka/` → type **jsonnet-via-tanka**. The **environment** (subpath inside tanka) is given by the Application's **plugin.env**: find the entry with `name: TK_ENV` and use its `value` (e.g. `apprise`). The full environment path is then `tanka/environments/<TK_ENV>` (e.g. `tanka/environments/apprise`). Link to that environment's `application.yaml`, `main.jsonnet`, `spec.json`.
    - Otherwise → type **bunch-of-files** (directory of raw manifests).
- Scan the entire Application YAML (including nested `valuesObject`) for `{{ .Values.<name> }}` or `{{ required "..." .Values.<name> }}`. Extract every distinct variable name (e.g. `cluster_name`, `vault_name`, `nfs_server`, `cluster_nfs_path`). These are the **bootstrap/TF variables** used by this component.

### 2. Map components to Terraform files

- List all `.tf` files in `tf/modules/k8s-cluster/` (e.g. `k8s-cert-manager.tf`, `external-dns.tf`, `apprise.tf`).
- In each file, look for comment lines such as `# Component: cert-manager` or `# Application: charts/cert-manager/application.yaml`. Use these to map a .tf file to a component name. If a component is listed in such a comment, that component has a **dedicated TF module**; link to that .tf file in the Configuration section and list the variables used (from step 1).

### 3. In-repo Helm charts (path points into charts/)

- For Applications whose `spec.source.path` is under `charts/` and contains `Chart.yaml`, read that Chart.yaml. Note `dependencies` (name, version, repository) and/or `appVersion`. This is "what the chart installs" (upstream chart name and version). If there is a `values.yaml` in that chart directory, you will link to it; otherwise do not link to a values file.

### 4. Build the component list and detect gaps

- **Component list**: Merge all Application names (and any chart directory names that correspond to applications) into a single deduplicated list of components. Normalize names to a slug suitable for filenames (e.g. `nfs-csi-driver`, `grafana`).
- **Existing files**: List every file in `Tiles/Software/` (e.g. `alloy.md`, `grafana.md`). Match by normalized name.
- **New components**: Components that appear in the discovered list but have **no** corresponding file in `Tiles/Software/` must **not** be auto-created. Collect the list of such components and **present it to the user**; ask what to do (create file, skip, or use a different name).
- **Dead links**: If a file in `Tiles/Software/` appears to refer to a component or Application that no longer exists in the tiles repo (e.g. the Application manifest was removed or renamed), treat that as a dead link. List those files and **ask the user to confirm removal or update** before deleting or changing them.

## Data Mapping

For each component that has an existing file in `Tiles/Software/`, populate the following. (For new components, only do this after the user has confirmed creation.)

| Source | Configuration section field |
|--------|-----------------------------|
| Application `metadata.name` + chart/path | Short summary (one or two sentences: what the component is and how it's deployed). |
| `spec.source` (chart+repoURL vs path + path contents) | **application.yaml type**: one of `helm`, `bunch-of-files`, `jsonnet-via-tanka`. |
| `spec.source.repoURL`, `path`, `chart` | **Where loaded from**: concise (e.g. "Helm chart from Grafana repo" or "In-repo path charts/cilium"). |
| `spec.source.targetRevision` or Chart.yaml version/dependencies | **Version deployed**: e.g. `4.12.1`, `main`, or chart version. |
| Path to Application manifest; path to values.yaml if present | **Links**: GitHub URLs only. Base: `https://github.com/symmatree/tiles/blob/main/`. Link to the application manifest (e.g. `charts/argocd-applications/templates/nfs-csi-driver-application.yaml`). Link to `values.yaml` **only if** the component is an in-repo Helm chart and that file exists (e.g. `charts/cert-manager/values.yaml`). For template-only apps there is no values file to link. |
| Chart.yaml + dependencies (when path is in-repo chart) | **If hosted in our repo**: one-line summary of what the chart installs (upstream chart name and version from Chart.yaml). |
| Presence of `{{ .Values.* }}` in template; tf/modules/k8s-cluster comments | **TF / bootstrap values**: If the Application uses any `.Values.*` or the component has a dedicated .tf file in tf/modules/k8s-cluster: set **Yes**, **link to the .tf file(s)** (GitHub URL), and **list the variables used** (e.g. cluster_name, vault_name, nfs_server) as extracted from the template. Otherwise **No**. |
| For jsonnet-via-tanka: plugin.env TK_ENV | **Tanka**: Report environment path (e.g. tanka/environments/apprise) and link to that environment's application.yaml, main.jsonnet, spec.json (GitHub URLs). |
| Same as TF/bootstrap (use of .Values) | **Varies between prod and test**: Yes + brief note (e.g. "Configuration varies by environment (cluster_name, vault_name, etc.).") or No. |

## File Naming and Location

- **Directory**: `Tiles/Software/` (at the facts repo root).
- **Filename**: `<component>.md` where component is the normalized Application name or chart directory name (e.g. `nfs-csi-driver.md`, `grafana.md`, `apprise.md`). No `README-` prefix.
- **New components**: Do not create new files until the user has been shown the list and has said which to create, skip, or rename.

## Document Structure: the Configuration Section

Each file in `Tiles/Software/` may contain other sections (Overview, Architecture, etc.). You only **add or replace** the section titled exactly:

```markdown
## Configuration
```

That section runs from that heading until the **next** `##` heading or the end of the file. Content must include (in order):

1. **Short summary** – One or two sentences.
2. **application.yaml type** – One of: `helm`, `bunch-of-files`, `jsonnet-via-tanka`.
3. **Where loaded from** – One line (repo/path/chart).
4. **Version deployed** – e.g. `4.12.1` or `main`.
5. **Links** – GitHub links only (`https://github.com/symmatree/tiles/blob/main/<path>`). List application manifest; if applicable values.yaml; if applicable .tf file(s); for Tanka, environment application.yaml, main.jsonnet, spec.json.
6. **If hosted in our repo** – Only if the component is an in-repo chart; one line on what the chart installs (upstream name/version).
7. **TF / bootstrap values** – Yes or No. If Yes: link to .tf file(s) and list variables used (e.g. cluster_name, vault_name, nfs_server).
8. **Tanka** – Only for jsonnet-via-tanka: environment path and links to environment files.
9. **Varies between prod and test** – Yes with brief note, or No.

After the Configuration section content, add a **footnote** (on the same day you run the procedure):

```markdown
*Configuration section updated by tiles-software-data-collection on YYYY-MM-DD. See [[kb/tiles-software-data-collection]] for update instructions.*
```

Use the actual current date for YYYY-MM-DD.

## Index: kb/things.md and Tiles/Software/README.md

- **kb/things.md**: The procedure updates the **Tiles/Software** section in this file. The section should follow the same pattern as "GitHub repos" and "UniFi devices": a short intro line (e.g. "Maintained by [[tiles-software-data-collection]]. Output directory: `Tiles/Software/`.") and then a list of links, one per component file (e.g. `- [[Tiles/Software/grafana]]`). Regenerate this list from the discovered components that have a corresponding file in `Tiles/Software/` (after resolving new components and dead links with the user).
- **Tiles/Software/README.md**: This file should exist and contain only a short note that links to (1) this procedure ([[tiles-software-data-collection]]) and (2) the Tiles/Software section in kb/things.md. Do not duplicate the full list of components here.

## Update Process (summary)

1. Ensure the tiles repo is available at the path the user provides (or default location).
2. Discover all Application manifests (templates + chart application.yamls); infer type (helm / bunch-of-files / jsonnet-via-tanka) and extract version, path, variables used.
3. Scan tf/modules/k8s-cluster/*.tf and map .tf files to components via comments.
4. Build the component list; compare with existing files in Tiles/Software/. Identify **new components** (no file) and **dead links** (file exists but component no longer in repo or target missing).
5. **Ask the user**: report new components and ask what to do (create/skip/rename); report dead-link files and ask for confirmation before removal or update.
6. For each component that has an existing file (and any new files the user asked to create): replace only the `## Configuration` block with the new content and add the collection-date footnote. Do not edit or fix user-written content; preserve all other content in the file exactly.
7. Update the Tiles/Software section in kb/things.md with the current list of component links.
8. Ensure Tiles/Software/README.md exists and links to this procedure and to the section in kb/things.md.

## Configuration Section Example (target format)

Below is a minimal example of how the Configuration section should look for a component that uses bootstrap values and has a TF file. Adapt to the actual data for each component.

```markdown
## Configuration

- **Short summary**: NFS CSI driver for Kubernetes; provides StorageClass `cluster-nfs`. Deployed via Helm from kubernetes-csi repo.
- **application.yaml type**: helm
- **Where loaded from**: Helm chart `csi-driver-nfs` from https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
- **Version deployed**: 4.12.1
- **Links**:
  - Application: [nfs-csi-driver-application.yaml](https://github.com/symmatree/tiles/blob/main/charts/argocd-applications/templates/nfs-csi-driver-application.yaml)
  - (No values.yaml in repo; values in Application valuesObject.)
- **TF / bootstrap values**: Yes. Variables used: nfs_server, cluster_nfs_path. TF: [k8s-cluster](https://github.com/symmatree/tiles/blob/main/tf/modules/k8s-cluster) (no dedicated .tf for this component; values from app-of-apps).
- **Varies between prod and test**: Yes. Configuration varies by environment (nfs_server, cluster_nfs_path differ per cluster).

*Configuration section updated by tiles-software-data-collection on YYYY-MM-DD. See [[kb/tiles-software-data-collection]] for update instructions.*
```

(Note: If the component had a dedicated .tf file, the TF line would link to that file and list it. Variables are those found in the Application template's valuesObject.)

## Notes

- **GitHub base URL**: Use `https://github.com/symmatree/tiles` and branch `main` for all links unless the user specifies otherwise.
- **Component name normalization**: Use Application `metadata.name` as the primary name; normalize to lowercase, hyphen-separated slug for the filename (e.g. `nfs-csi-driver`).
- **Related software**: Detecting "related software" (e.g. dependencies or linked components from YAML) is not part of this procedure; it may be added in a future revision.
