# `.github/workflows` – GitHub Actions Orchestration

This folder contains the **two GitHub Actions workflows** that orchestrate:
1) deploying to the EC2 host, and
2) publishing documentation **after a successful deploy**.

> **Principle**  
> GitHub Actions here is the orchestrator. The EC2 host scripts do the real work.

---

## Contents

```
.github/workflows/
├── deploy_to_ec2_AWSPRDDWH001.yml
└── docs_publish.yml
```

---

## `deploy_to_ec2_AWSPRDDWH001.yml`

### Purpose
CI/CD dbt and airflow, deploy the repo to the EC2 host using the host’s release/deploy scripts (immutable releases + atomic `current` symlink switch), promotes validated changes from qa branch to master branch.

### When it runs
- `push` to `qa`
- Manual run (`workflow_dispatch`)

### What it does (high level)
- Runs on the **self-hosted runner** installed on the EC2 host
- Passes deployment context (`GITHUB_SHA`, `GITHUB_REF_NAME`) to the host deploy entrypoint script

---




## `docs_publish.yml`

### Purpose
Publish documentation artifacts (for example, dbt docs) **only after** the deploy workflow completes successfully.

### When it runs
This workflow runs **automatically** after the deploy workflow finishes because it is triggered by `workflow_run` and gated by the deploy conclusion.

Specifically, the publish job uses:

```yaml
publish_docs:
  if: ${{ github.event.workflow_run.conclusion == 'success' }}
```

So the sequence is:
1) Deploy workflow completes
2) If deploy conclusion is `success`
3) Docs publish workflow starts automatically

✅ **It is not a manual-only workflow** in the current setup.

### Known / expected failure case (important)
Docs publishing can fail after **manual deploy runs** when the deploy workflow **does not actually deploy anything** (for example, no new commit/release or no changes), so documentation is **not re-created**.

In that case:
- deploy workflow may still be marked **success** in GitHub
- docs publish runs automatically due to `workflow_run`
- but publish can fail because there are no new docs artifacts to publish

---

## Relationship Between Workflows

These workflows are **chained** (one after the other), not “blocking” within one job:

1. **Deploy** runs first (`deploy_to_ec2_AWSPRDDWH001.yml`)
2. **Docs publish** runs second (`docs_publish.yml`) automatically via `workflow_run`, **only if** deploy concluded successfully (`publish_docs.if == success`)

This design keeps:
- production deploy logic clean and authoritative on the host
- docs publishing decoupled and retryable without redeploying

---

## Where to read the real operational docs

- **Deploy / release scripts & behavior**: README in the `deploy/` folder
- **EC2 + Airflow runtime restore and operations**: README in the `airflow_runtime/` folder
