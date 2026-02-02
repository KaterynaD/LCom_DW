# CI/CD Architecture & Operations Guide

This README documents **the final CI/CD design, decisions, and operational practices** for this repo.

It is written so that you can:
- rebuild CI/CD behavior on a **brand-new EC2 host**
- understand **why things are structured this way** (not just how)
- safely operate, debug, and extend the pipeline without surprises

---

## 1. CI/CD Goals (Non-Negotiables)

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
- `deploy_release.sh` – core host deploy logic
- `deploy_release_from_actions.sh` – GitHub Actions entrypoint
- `publish_dbt_docs.sh` – non-blocking docs publishing

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
Docs failure never breaks production.

These commands are run in deploy_release_from_actions.sh
```
dbt docs generate --static 
colibri generate 
```

In publish_dbt_docs.sh: The output files in /home/kdrogaieva/Prod/dbt_target are renamed and copied to /home/kdrogaieva/Prod/docs folder and pushed to docs branch of learningcom/transformations.git
---

## 12. Observability

Logs live in:

```
/home/kdrogaieva/Prod/deploy/logs
```

Host logs are the source of truth.

---

## Final Rule

> **Nothing is deployed until the symlink moves.**
