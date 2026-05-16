# Tiles program and handover notes

Rolling backlog for getting **test** and **prod** Kubernetes clusters (Tiles) working and maintainable. This is intentionally a grab bag, not a single scoped project.

**Handoff loop (only path for program updates from execution work):**

1. Coordinator writes an **outgoing handoff** under **`~/handoffs/`** (unless you specify another path).
2. You run the execution agent against that doc.
3. When the work is done, the execution agent writes a **return handoff** (what to call it and where lives in the outgoing handoff or your standing convention).
4. You tell the coordinator to **read that return handoff**.
5. Coordinator merges what matters into **`TODO.md`**. That file is the return; not chat fragments, not vibes.

**What belongs in git here:** by default **only this `TODO.md`** for program tracking. **`~/handoffs/`** holds outgoing and return handoffs and other local notes you do not want in facts/tiles. **Do not** add sibling markdown under `facts/fables/Tiles/` or open **GitHub issues** for this program unless **you** explicitly chose that for a given effort. Normal **code** still lands via the usual repo PR flow; that is separate from the handoff loop above.

**Successor coordinators:** read this whole file before acting, and **edit this `TODO.md`** after you point them at the **return handoff** (or when you edit state yourself).

**Execution agents** (spawned from a handoff): **do not edit `TODO.md`.** Write the **return handoff**; the coordinator only updates `TODO.md` after the operator says to read it.

---

## Role of the coordinator agent

The human runs **execution agents** directly (often with adjusted instructions). The coordinator:

- Writes **outgoing handoff** docs under **`~/handoffs/`** (unless you say otherwise). Each outgoing handoff tells the executor: **do not modify `facts/fables/Tiles/TODO.md`**, and how/where to write the **return handoff** when done.
- **Does not edit an issued outgoing handoff after you received it.** Same race as `TODO.md`. If something must change mid-flight, the coordinator edits **`TODO.md`** or writes a **new** handoff file with a **new** name -- never silent edits to the old outgoing doc.
- **Reads the return handoff** you name, then **merges** into **`TODO.md`**. No substitute channel for that step.
- Keeps its own context **light** -- survey and plan, minimal direct cluster work unless asked.

The main **IaC and GitOps** repo is **`symmatree/tiles`** (local clone often `tiles/`). Operational inventory and mirrored software KB live in **`facts`** under **`facts/fables/`** (submodule; same content may appear as `tiles/fables/` in a tiles clone -- treat as duplicate and do not maintain two sources).

**Documentation domains to care about:** Talos Linux, Proxmox, Terraform, Kubernetes, 1Password, GCP -- plus Argo CD / Helm as deployed from tiles.

---

## Conventions and facts (update as they change)

- **Program tracker:** this file, `facts/fables/Tiles/TODO.md`.
- **Kubernetes contexts (for `kubectx`):** use the names in the merged kubeconfig. **`tiles/docs/dev-setup.md`** documents Talos-style defaults (**e.g.** `admin@tiles-test`, `admin@tiles`); cluster **names** are still `tiles-test` / `tiles` in the rest of the stack. No multi-user kubeconfig story required for now.
- **Operator machine (from `~/handoffs/kubeconfig-workstream-return.md`, not re-verified here):** staging `~/.kube/tiles-test.yaml` and `~/.kube/tiles.yaml` (prod file is `tiles.yaml`); merged default via `kubectl config view --flatten` into `~/.kube/config`; on WSL, `op.exe` when Linux `op` is not signed in.
- **Grafana (gitops):** Ingress host pattern is `borgmon.<cluster_name>.symmatree.com` from `tiles/charts/argocd-applications/templates/grafana-application.yaml` (Helm `valuesObject` on the Argo Application). Shorthand: `borgmon.tiles-test...` and `borgmon.tiles...` when `cluster_name` is `tiles-test` vs `tiles`.
- **Cross-cluster access:** Not guaranteed by docs alone. Operator hypothesis: public-ish `10.x` node or ingress reachability may work between environments; pod and service CIDRs are per-cluster and routing between clusters is **uncertain** -- verify with live network checks, not assumptions.

---

## Documentation map (where truth lives)

**tiles repo (`docs/`, `tf/`, `charts/`, `.github/workflows/`):**

- Entry: `docs/index.md`.
- Test vs prod / CI: `docs/environment-strategy.md`.
- Value flow TF to 1Password to Argo: `docs/config-propagation.md`.
- Secrets and vault layout: `docs/secrets.md`; local kube/talos from 1Password: `docs/dev-setup.md` (**kubeconfig for both clusters, merge workflow** -- **PR 412** merged to **`main`**).
- Talos / network narrative: `docs/talos.md`, `docs/cluster-network.md`, `docs/bare-metal-nodes.md` (metal details defer to `facts/fables/Tiles/Rising.md`).
- Terraform: `tf/nodes/README.md`, `tf/bootstrap/README.md`.
- App-of-apps: `charts/argocd-applications/README.md`, bootstrap order in `.github/workflows/bootstrap-cluster.yaml`.
- GCP: `docs/gcp-enterprise-setup.md`.

**dotfiles-symm:** README Kubernetes section points at **`tiles/docs/dev-setup.md`** (merged per **`~/handoffs/kubeconfig-workstream-return.md`**; unrelated local changes in that repo are separate).

**facts/fables (this submodule):**

- Cluster picture and hardware: `Tiles/Tiles (cluster).md`, VM sheets (`tiles-cp-*.md`, `tiles-wk-*.md`, `tiles-test-*.md`), `Tiles/ProxMoxNodeSetup.md`, `kb/unifi/docs/logical.md`, `kb/things.md`.
- KB procedures: `kb/tiles-software-data-collection.md`, `kb/tiles-software-logs.md`, `kb/proxmox/proxmox-data-collection.md`.
- Per-component mirror: `Tiles/Software/*.md` (links into tiles charts/TF).
- Kubeconfig design (operator / agents): **`~/handoffs/kubeconfig-and-contexts.md`** (local handoff, not in repo).

**Doc drift sprint (2026-05-03):** **Closed.** Tiles: `docs/cluster-network.md` and `docs/components.md` realigned to Terraform and app-of-apps layout. New **`.cursor/rules/markdown-link-sources.mdc`** in **tiles** and **facts** (link config at GitHub `main`, path as link text; avoid giant pasted excerpts). Optional follow-up: slow audit of other `docs/*.md` against that policy. Processed doc-drift handoffs were removed from `~/handoffs/` after merge.

**Which Argo apps exist:** Authoritative list is **`charts/argocd-applications/templates/*-application.yaml`** (22 in that pass), including symlinks into `charts/` or `tanka/` -- do not assume every workload has **`charts/<name>/application.yaml`**.

**Terraform `tf/modules/k8s-cluster/`:** In the current tree this module is **small** (cert-manager, external-dns, dns, apprise, etc.). Do **not** cite **`loki.tf` / `mimir.tf`** there unless those files exist again.

**Still not git-decidable:** Cross-cluster reachability, Grafana from the other cluster, pod/service CIDR routing -- **live network verification** only.

**Prior design brainstorm (optional context):** **`~/handoffs/kubeconfig-and-contexts.md`** -- superseded for procedure by **`tiles/docs/dev-setup.md`** on **`main`** (post-412).

---

## Workstream 1 -- Kubeconfig, kubectx, dotfiles, agent surfacing

**Status (merged from `~/handoffs/kubeconfig-workstream-return.md`):** **`tiles/docs/dev-setup.md`** on **`main`** (PR **412** merged): both clusters, `op read`, safe `.part` + `mv`, merge into **`~/.kube/config`**, optional **`KUBECONFIG`**, refresh note, default context names **e.g.** `admin@tiles-test`, `admin@tiles`. **`dotfiles-symm`** README Kubernetes section **merged** (points at tiles doc). **New tiles rule:** **`.cursor/rules/fables-submodule-handling.mdc`** (`alwaysApply`) -- no detached `fables/` SHA checkout churn; submodule refresh stays on `main` + commit gitlink when asked. **`kubectx`** ergonomics unchanged: install already in dotfiles; contexts come from merged kubeconfig.

**Still open:** optional **skills** / Cursor surfacing **if you want it** later.

**Do not resurrect:** further agent-driven **`fables`** verify/stash/checkout-SHA work for this thread (rule states intent).

**Goal (original):** local **`kubectl`** / **`kubectx`** to both clusters from **1Password**, documented canonical path **without** improvisation -- **done**.

---

## Workstream 2 -- Test vs prod application configuration

**Deferred for now:** operator chose to sequence **cluster status** (workstream 3) first.

**Goal:** A **documented mechanism** for installing different apps or **different Helm values** in test vs prod.

**Requirements from operator:**

- Fitting everything on a **single machine** for test is nice but must **not** limit what prod can run.
- Likely direction: extend **app-of-apps** so each app can load **`values-${environment}.yaml`** in addition to **`values.yaml`**.
- Per-app `application.yaml` (or equivalent) can take values from those env files and/or **conditionalize on environment name**.
- Optionally wrap whole Application resources in a flag like **`fooEnabled`** so test can omit heavy apps without commenting ad hoc (or comment-out remains acceptable if documented).

**Design anchors in tiles:** `docs/environment-strategy.md`, `docs/config-propagation.md`, `charts/argocd-applications/`.

**Exit ideas:** Written pattern + at least one reference app using env-specific values; prod not constrained by test topology choices.

---

## Workstream 3 -- Cluster status (test first, then prod)

**In progress:** operator has **Kubernetes MCP** plus kubeconfig that should match **`tiles/docs/dev-setup.md`** (`main`). **test** cluster first, then **prod**.

**Goal:** Establish **current status** for each cluster, **one cluster at a time** (test first, then prod): control plane up, nodes, **alerts**, **degraded apps**, Argo health, etc.

**Rationale:** Doing both at once is harder; failures often correlate but triage should still be sequential.

**Exit ideas:** **Return handoff** with date, cluster, findings, enough context for the next execution pass; you point the coordinator at it for `TODO.md` merge.

**Recent status (operator, monitoring path):** **`k8s-monitoring`** aligned to a **single Alloy metrics path**: turned off **per-collector ServiceMonitors**; rely on **`integrations.alloy`** with **alloy-receiver** in discovery and extra **`includeMetrics`** for the Grafana **alloy-mixin**. **Argo Applications** added for **alloy-mixin** and **cert-manager-mixin** via the same **symlink into `argocd-applications`** pattern as other Tanka mixins. **Mixin `filterSelector`** set so dashboards track scrape **`job="integrations/alloy"`**. **Mimir** and raw **`/metrics`** checks: **`cluster_name`** emitted by Alloy on clustering-enabled roles and empty on others (**matches product behavior**, not relabel loss). **alloy-mixin** app briefly hit known Argo CD CMP surface error (**could not find plugin supporting the given repository**) -- same stalled-stream / misleading-message pattern as **`tiles/docs/argocd-cmp-stalls-investigation.md`**; went green after a couple refreshes. **Follow-up:** hardening pass (repo-server / explicit **`plugin.name`**, deadlines); rollout operationally OK.

---

## Workstream 4 -- Branches and PRs on tiles (low priority)

**Goal:** Review open **branches** and **PRs** on the **tiles** repo, note **intent** and **gaps** for each, then **revive** (rebase, finish, merge) or **close** intentionally.

**Exit ideas:** **Return handoff** lists each PR or branch with explicit outcome (merged / closed / etc.); you point the coordinator at it for `TODO.md` merge.

---

## Workstream 5 -- MCP servers (Kubernetes and Grafana)

**Goal:** MCP servers for **Kubernetes** and **Grafana**.

**Direction from operator:** Prefer a **single MCP deployment in prod** that can target **both** clusters where possible, to save **tool count** and **deploy resources**.

**Docs:** Clear **agent-facing** documentation on **how** and **when** to use these MCPs (which cluster, which Grafana URL, auth notes if any).

**Grafana URLs:** Cluster ingress as in "Conventions" (borgmon host pattern). Reachability from an MCP pod or from a developer machine is an **implementation detail** to verify, not assumed.

**Exit ideas:** Running MCP(s) + short doc for coordinators and execution agents.

---

## Workstream 6 -- Per-software knowledge base (facts)

**Goal (operator roadmap, not self-serve for agents):** For **each piece of software** deployed via tiles, a **knowledge base entry** in `facts/` or `facts/fables` with:

- **High signal, very low noise.**
- Short description.
- Links to **upstream chart** and **underlying product** docs.
- **Longer text only** for: **local** customizations and operator **choices**; and for **documented** failure patterns -- including **commands** to test, **logs** to inspect, and what **good** logs look like when that is actually known.

**Epistemic rule:** Be precise about what is evidenced. Do **not** write "often it is X" when the repo only knows "one cause of symptom S is X".

**Scope:** This needs its own **styleguide and iteration plan** (tooling for consistency). **Defer** kicking that off in earnest until **workstream 5** (MCP) is in good shape -- operator experience: MCP makes agents much more effective on deployments like this.

---

## Principles (operator preferences)

- **Prefer asking** over assuming when the answer materially changes work -- but if you ask, **do the background reading first** so the question is not lazy (do not ask the operator to substitute for reading docs or logs you could read).
- If you notice yourself **flipping approach back and forth**, treat it as a **close call** -- the operator may have **unstated constraints**; ask with specifics.

---

## Retrospective: doc drift as "do first" (2026-05-03)

**Operator read:** Framing doc drift as **"do this first, everything else will be easier"** did not pay off relative to that promise. The execution agent fixed the approved scope with **little operator help** beyond rejecting bad rows -- a sign it was **not** a gap that blocked other agents from making progress on real cluster work.

**Coordinator learning:** Avoid promoting **optional doc hygiene** to a **gating prerequisite** unless there is a **concrete** downstream failure (broken links blocking a procedure, repeated wrong paths in incidents). Prefer a **small handoff when drift hurts a task**. Handoff item **"README should explain facts vs tiles"** was **ill-formed** here: it collided with **tiles not advertising private facts**, **`fables` as the public submodule**, and the **existing** rule **`.cursor/rules/fables-edit-in-facts.mdc`**. Do not reopen similar rows without a **cited** reader failure (404, wrong clone) and respect **private-repo** boundaries.

**Execution process (from return handoff):** Confirm **intended base branch** with the operator before writing commits (avoid landing work on a branch that was **already merged**). **Return handoff** at end of execution is **required** for this program's loop, not optional.

---

## Changelog (coordinator edits)

| Date | Who | Note |
|------|-----|------|
| (fill) | | Initial expanded TODO from coordinator handover. |
| 2026-05-03 | Coordinator | Clarified: execution agents must not edit `TODO.md`; handoffs say so; coordinator merges from returned handoffs. |
| 2026-05-03 | Coordinator | Coordinators must not edit issued handoff files in place; same race as editing `TODO.md` under others. |
| 2026-05-03 | Coordinator | Doc drift sprint merged (tiles PR); retrospective on "do first" framing; optional markdown pass on other docs. |
| 2026-05-03 | Coordinator | Removed invented submodule / argocd-pr-diff backlog; trimmed doc-drift summary of argocd workflow; kubeconfig design doc; workstream 1 debiased from script-first. |
| 2026-05-03 | Coordinator | Kubeconfig design moved to `~/handoffs/kubeconfig-and-contexts.md`; processed doc-drift handoffs deleted from `~/handoffs/`. |
| 2026-05-03 | Coordinator | Tightened scope: default tracking is this file + `~/handoffs/`; no extra repo docs or GitHub issues unless operator explicitly opts in per effort. |
| 2026-05-03 | Coordinator | Handoff loop spelled as you defined it: outgoing -> work -> return handoff -> you tell coordinator to read -> merge `TODO.md`; removed invented alternate channels. |
| 2026-05-06 | Coordinator | Merged `~/handoffs/kubeconfig-workstream-return.md`: workstream 1 status (tiles PR 412, dotfiles README, `fables-submodule-handling.mdc`); conventions + snapshot updated. |
| 2026-05-06 | Operator | Tiles PR **412** on **`main`**; workstream 2 deferred; workstream **3** in progress (kubectl/MCP status, test then prod). |
| 2026-05-09 | Operator | Workstream 3 note: k8s-monitoring single Alloy path, alloy-mixin + cert-manager-mixin Argo apps (Tanka symlink pattern), `job=integrations/alloy`, `cluster_name` checks, CMP stall then green; see **`tiles/docs/argocd-cmp-stalls-investigation.md`**. |
