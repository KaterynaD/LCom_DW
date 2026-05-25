# CI/CD Architecture & Operations Guide

This README documents **the final CI/CD design, decisions, and operational practices** for this repo.

It is written so that you can:
- rebuild CI/CD behavior on a **brand-new EC2 host**
- understand **why things are structured this way** (not just how)
- safely operate, debug, and extend the pipeline without surprises

---
TBD

Database objects created outside of dbt , even if they can be created via dbt macros are NOT part of the deployment
Views, even if there is a corresponding dbt model are NOT created in the deployment process
---

## 1. CI/CD Goals

The CI/CD system is designed around the following hard requirements:

1. **Immutable releases** (SHA-based)
2. **Atomic deploys** (symlink flip only)
3. **Fast rollback** (one command)
4. **Host-local execution** (no SSH deploys)
5. **Separation of concerns**
   - GitHub Actions = orchestration
   - Host scripts = authority
6. **Safe failure**
   - partial deploys never become active
   - broken deploys never corrupt the previous release

This is *not* a container-only or GitHub-only deployment model. The **EC2 host is stateful by design**.

---

## 2. High-Level CI/CD Flow

```
GitHub (push / manual)
        ↓
GitHub Actions (self-hosted runner on EC2)
        ↓
Stable host deploy script
        ↓
Immutable release directory (by SHA)
        ↓
Validation (dbt, dags, docs)
        ↓
Atomic symlink switch (current → new SHA)
```

Key principle:
> **GitHub Actions never deploys directly. It only asks the host to deploy.**

---

## 3. Host-Level Directory Model (Final)

```
/home/kdrogaieva/Prod
├── repo-mirror/
├── releases/
│   └── <sha>/transformations/
├── current -> releases/<sha>/transformations
├── deploy/
│   ├── bin/
│   ├── locks/
│   └── logs/
├── docs/
└── airflow_runtime/
```

---

## 4. repo-mirror Strategy

The repo mirror is a **bare clone** used only for worktrees and fetches.

```
git clone --mirror git@github.com:learningcom/transformations.git /home/kdrogaieva/Prod/repo-mirror
```

---

## 5. Release Creation

Each deploy creates a new immutable directory:

```
/home/kdrogaieva/Prod/releases/<SHA>/transformations
```

Created via git worktree. Releases are never mutated after creation.

---

## 6. Atomic Activation

Deployment success is defined by **one operation only**:

```
ln -sfn /home/kdrogaieva/Prod/releases/<SHA>/transformations /home/kdrogaieva/Prod/current
```

If this line does not run, **no deployment happened**.

---

## 7. Deployment Scripts

Location:

```
/home/kdrogaieva/Prod/deploy/bin
```

Scripts:
- `deploy_release_from_actions.sh` – deploy_to_ec2_AWSPRDDWH001 GitHub Actions entrypoint
- `publish_dbt_docs.sh` – docs_publish GitHub Actions entrypoint

---

## 8. GitHub Actions Role

GitHub Actions:
- runs only on the self-hosted runner
- passes SHA + branch
- never performs git operations itself

All authority lives on the host.

---

## 9. Locking & Safety

A deploy lock ensures:
- only one deploy at a time
- crashes auto-release the lock

Failures never touch `current`.

---

## 10. Rollback

Rollback is instant:

```
ln -sfn <previous_sha>/transformations current
```

No rebuild. No redeploy.

---

## 11. Docs Publishing

Docs are generated during deploy but published *after activation*.

These commands are run in deploy_release_from_actions.sh (deploy_to_ec2_AWSPRDDWH001 GitHub Action runner)

```
dbt docs generate --static 
colibri generate 
```

In publish_dbt_docs.sh (docs_publish GitHub Action runner starts automatically when when deploy_to_ec2_AWSPRDDWH001 is successeded): The output files in /home/kdrogaieva/Prod/dbt_target are renamed and copied to /home/kdrogaieva/Prod/docs folder and pushed to docs branch of learningcom/transformations.git


## 12. Testing of the New Release

All release testing is orchestrated in `deploy_release_from_actions.sh` and includes both dbt and Airflow validation steps:

### dbt Validation


- `dbt compile` is run in the current release with `--vars '{"loaddate": "1900-01-01"}'` to ensure consistent model state comparison (the same `loaddate` is required for accurate diffing).
- The manifest from the current working release is saved to `STATE_DIR="$DBT_TARGET_PATH/latest_prod_artifact"`.
- The new release is deployed and `dbt deps` is executed to install dependencies.
- `dbt compile` is run again (with the same `loaddate`) to generate a new manifest for the new release.
- The old and new manifests are compared, and a list of changed models is printed.
  - If `RUN_QA_STATE_TESTS` is set to `true` and there are dbt modified models:
    - The QA database is cleaned of all schemas using a dbt macro.
    - A `dbt run` is performed in the QA target with `state:modified`, `--empty`, and `--defer` to test the SQL of modified models.
    - TBD preparation QA environment for SQL materialization (Sstored procedures and tables are created in QA) I may remove this step soon.
    - Profiling materialization are not validated (and Profiling is very slow and need a specific target)
    - List of modified views is sent to validate_views macro and select runs. This is required to validate No Schema Binding Redshift views. If no errors, modified view materialized models are deployed in Prod once because they are not part of routing daily runs.

- Documentation and column-level lineage are generated:
  - `dbt docs generate`
  - `colibri generate`

### Airflow DAG Validation

- `dev_check_dags.py` is executed and must report "No import errors".

### Failure Handling

If any of the above steps fail, a rollback is triggered and the system reverts to the previous working release.

### colibri generate errors

You may see errors in the output of colibri. There are some models where it can not process. It is not a command failure and can be ignored.
---

## 13. Observability

Logs live in:

```
/home/kdrogaieva/Prod/deploy/logs
```

Host logs are the source of truth.

---

## Final Rule

> **Nothing is deployed until the symlink moves.**
