# GitHub Repo Data Collection Process

## Overview

This document describes the process for collecting and maintaining "baseball card" metadata about GitHub repositories under the Symmatree account (GitHub user, not an organization). Data is collected using the GitHub REST API via the `gh` CLI. Output files live in `GithubRepos/`.

**When following this process:** Use the actual current date whenever the procedure calls for a date (e.g. collection-date footnote). If you encounter a value that seems unlikely, ask the user rather than changing it. Do not "fix" or correct source/API values—record them as given.

## Prerequisites

- **gh CLI**: Install [GitHub CLI](https://cli.github.com/) and authenticate **as the Symmatree account** with `repo` scope so the API can list private repos:
  ```bash
  gh auth login -h github.com -s repo
  ```
  If you already have an account linked, add the scope with `gh auth refresh -h github.com -s repo`.
- Use the **authenticated user** list endpoint (see below), not the public "users/symmatree/repos" endpoint, so private repos are included.

## Data Collection Method

### 1. List repositories

List repos for the **authenticated user** (includes private when token has `repo` scope). Filter to Symmatree-owned repos so the set is correct even if the token can see other accounts' repos:

```bash
gh api user/repos --paginate --jq '.[] | select(.owner.login == "symmatree") | .name'
```

- **Endpoint:** `user/repos` = "repositories for the authenticated user." Use this, not `users/symmatree/repos` (which lists only **public** repos for that username).
- **Scope:** Token must have `repo` scope for private repos to appear.
- **Fallback:** If a repo you care about (e.g. one that already has a file in `GithubRepos/`) does not appear in this list, add its name to the set for this run (e.g. from existing filenames: `facts`, `ha-config`, or names from `*-repo.md` / existing docs). Then run step 2 for every name in the set so every card is updated in one pass.

### 2. Fetch metadata per repo

For **each** repo name in the set (from step 1, plus any names added in the fallback), request metadata (one call per repo; no clone):

```bash
gh api repos/symmatree/REPO --jq '{
  name, description, created_at, updated_at, pushed_at, size,
  language, stargazers_count, forks_count, open_issues_count,
  default_branch, private, archived, license: (.license.name // "none"), html_url
}'
```

Replace `REPO` with the repository name (e.g. `tiles`, `tales`, `facts`, `ha-config`).

### 3. Optional: languages breakdown

For a per-language byte breakdown (no line counts; GitHub does not expose LOC via API):

```bash
gh api repos/symmatree/REPO/languages
```

This is one extra call per repo; use only if you want language breakdown in the card.

## Data Mapping

Fields used for the baseball card (all from the single `repos/:owner/:repo` response):

| API field | Card use |
|-----------|----------|
| `name` | Repo name; used for filename and heading |
| `description` | Short description line |
| `html_url` | Link to repo on GitHub |
| `created_at` | Creation date (ISO 8601) |
| `updated_at` | Last metadata update |
| `pushed_at` | Last push to default branch |
| `size` | Repo size in KB (GitHub's approximation, not a full clone) |
| `language` | Primary language (null if undetected) |
| `stargazers_count` | Star count |
| `forks_count` | Fork count |
| `open_issues_count` | Open issues |
| `default_branch` | Default branch name |
| `private` | Visibility |
| `archived` | Archived flag |
| `license` | License name or "none" |

**Note:** GitHub does not expose "total changes" or "lines of code" via the REST API. Getting LOC would require cloning and a tool like `tokei` or `cloc`, which is slower; this process sticks to fast API-only data.

## File Naming and Location

- **Directory:** `GithubRepos/` (at the facts repo root).
- **Filename:** Use an existing file in `GithubRepos/` if one already refers to that repo (e.g. `tales.md`, `Tiles-Repo.md`, `facts.md`). Otherwise create a new file with the repo name and a `-repo` suffix: `{reponame}-repo.md` (e.g. `tiles-repo.md`, `action-storage-repo.md`). Use lowercase for the repo name in new filenames.
- **One entry per repo:** There should be exactly one file in `GithubRepos/` per repo under Symmatree that you are tracking.

## Document Structure (baseball card)

Each repo file in `GithubRepos/` should include a **GitHub Repo** section (or equivalent) with at least:

- **URL**: Link to the repo (`html_url`)
- **Description**: Repo description (or "No description" if null)
- **Created**: Creation date (human-readable, from `created_at`)
- **Last pushed**: Last push to default branch (from `pushed_at`)
- **Size**: Repo size (from `size` KB; show e.g. "X MB" or "Y KB")
- **Primary language**: `language` or "—" if null
- **Default branch**: `default_branch`
- **Stars / Forks / Open issues**: From `stargazers_count`, `forks_count`, `open_issues_count`
- **Visibility**: Public or Private
- **Archived**: Yes/No from `archived`
- **License**: License name or "None"

Add a footnote with collection date and pointer to this process:

*GitHub repo data collected via GitHub REST API (gh api) on YYYY-MM-DD. See [[github-repo-data-collection]] for update instructions.*

**Do not update user-written content.** Preserve any existing content in the file (e.g. notes, links to Obsidian vaults, clippings) above or below the GitHub Repo section. Only add or update the GitHub Repo section and its footnote. Do not edit, "fix," or rewrite links, wording, or other content that the user wrote.

## Update Process

1. **List repos**: Run `gh api user/repos --paginate --jq '.[] | select(.owner.login == "symmatree") | .name'` to get repo names. If any Symmatree repo you track already has a file in `GithubRepos/` but did not appear (e.g. `facts`, `ha-config`), add that repo name to the set so every card gets refreshed in this run.
2. **For each repo name in the set:**
   - **Fetch metadata**: `gh api repos/symmatree/REPO` with the jq filter from step 2 in Data Collection Method (or equivalent).
   - **Match to file**: Determine the doc file (existing file in `GithubRepos/` for that repo, or `{reponame}-repo.md` per File Naming).
   - **Update or create**: Update the GitHub Repo section in that file, or create a new `{reponame}-repo.md` with the full baseball card and footnote. Do not edit or fix user-written content; preserve any other content in the file exactly.
3. **New repos**: If the list included a repo that has no file yet, create `{reponame}-repo.md` with the standard section and footnote.
4. **Removed repos**: If a repo is no longer in the list and no longer under Symmatree, leave or archive its doc as appropriate; the next run will not include it.

## Data Source

All data is from the [GitHub REST API](https://docs.github.com/en/rest) via `gh api`. No local clone or third-party service is required for the fields described above.

## Notes

- **List endpoint:** Use `user/repos` (repos for the **authenticated** user), not `users/symmatree/repos`. The latter only returns public repos for that username; the former returns all repos the authenticated user can see (including private) when the token has `repo` scope. Authenticate as Symmatree and use `user/repos` so private repos (e.g. facts, ha-config) are included.
- **User vs org:** Symmatree is a user account; the list is `user/repos` (authenticated user), not `orgs/symmatree/repos`.
- **Rate limits:** Authenticated `gh` requests have higher rate limits; normal update runs are well within limits.
- **Missing from list:** If a repo still doesn't appear in `user/repos` (e.g. different owner or API quirk), add its name to the set for that run from existing `GithubRepos/` filenames, then run the same fetch-and-update steps for it so all cards are updated in one procedure.

## Procedure notes (from run)

- **2026-02-15 run:** Authenticated as Symmatree with `repo` scope. `gh api user/repos --paginate --jq '.[] | select(.owner.login == "symmatree") | .name'` returned 22 repos, including `facts` and `ha-config`. No fallback (adding names from existing files) was needed—the list was complete.
- **Size in API:** GitHub returns `size` in **KB**. For the card, use "X KB" when &lt; 1024, or "X.X MB" when ≥ 1024 (e.g. size/1024 with one decimal).
- **Null description:** Some repos have `description: null`. Use "No description" in the card.
- **Existing filenames:** Repos with existing docs use those filenames (e.g. `facts.md`, `ha-config.md`, `tales.md`, `Tiles-Repo.md`); new repos get `{reponame}-repo.md`. Matching is by repo name, not filename.
