# Appendix: Common Failure Scenarios & Fixes
# (CI/CD Runbook)

This appendix is intended as a **practical runbook** for on-call, maintenance, or future-you scenarios.
All commands assume execution on the **EC2 host** as user `kdrogaieva` unless noted otherwise.

---

## 1) GitHub Actions runner is down

### Symptoms
- GitHub Actions job stuck in **Queued**
- Message like:
  > "Waiting for a runner to pick up this job"

### Diagnosis
```bash
cd /home/kdrogaieva/actions-runner
sudo ./svc.sh status
```

### Fix
```bash
sudo ./svc.sh restart
sudo ./svc.sh status
```

If the service does not start:
```bash
sudo journalctl -u actions.runner.* --no-pager -n 200
```

### Last resort
Re-register the runner using a new token from GitHub UI.

---

## 2) Deploy is stuck due to a stale lock

### Symptoms
- Deploy script exits immediately
- Message mentions an existing lock file

### Diagnosis
```bash
ls -l /home/kdrogaieva/Prod/deploy/locks
cat /home/kdrogaieva/Prod/deploy/locks/deploy.lock
```

Check whether a deploy is actually running:
```bash
ps aux | grep deploy_release | grep -v grep
```

### Fix (safe)
If **no deploy process is running**, remove the lock:
```bash
rm -f /home/kdrogaieva/Prod/deploy/locks/deploy.lock
```

> Lock files are protected by `trap` logic; a stale lock usually means the host rebooted mid-deploy.

---

## 3) Bad release deployed (need rollback)

### Symptoms
- Airflow errors
- dbt failures (compile or run in QA)
- Application misbehavior after deploy

### Diagnosis
List available releases:
```bash
ls -1 /home/kdrogaieva/Prod/releases
```

Check current active release:
```bash
readlink -f /home/kdrogaieva/Prod/current
```

### Fix (instant rollback)
```bash
ln -sfn   /home/kdrogaieva/Prod/releases/<PREVIOUS_SHA>/transformations   /home/kdrogaieva/Prod/current
```

No rebuild. No redeploy. Rollback is immediate.

---

## 4) Deploy succeeded but nothing actually changed

### Symptoms
- Deploy workflow shows **success**
- Docs publish workflow fails
- No new code was released

### Explanation
This commonly happens on **manual workflow runs** where:
- the SHA already exists as the active release
- no new worktree is created
- documentation is not re-generated

Docs publishing may fail because there are **no new artifacts**.

### Action
- Safe to ignore
- Or re-run docs publish after forcing a new deploy (new SHA)

---

## 5) Repo mirror is out of sync

### Symptoms
- Deploy fails resolving SHA
- Worktree creation errors

### Diagnosis
```bash
cd /home/kdrogaieva/Prod/repo-mirror
git fetch --prune origin
git show -s --oneline HEAD
```

### Fix
```bash
git fetch --prune origin
```

The mirror is safe to refresh at any time.

---

## 6) Partial / broken release directory exists

### Symptoms
- A release directory exists but deploy failed mid-way

### Diagnosis
```bash
ls -l /home/kdrogaieva/Prod/releases/<SHA>
```

Check if it is active:
```bash
readlink -f /home/kdrogaieva/Prod/current
```

### Fix
If **not active**, it is safe to delete:
```bash
rm -rf /home/kdrogaieva/Prod/releases/<SHA>
```

Never delete the directory pointed to by `current`.

---

## 7) Airflow containers not running after deploy

### Diagnosis
```bash
cd /home/kdrogaieva/Prod/airflow_runtime
docker compose ps
```

### Fix
```bash
./start_airflow.sh
```

Check logs:
```bash
docker compose logs -f airflow-webserver
```

---

# Appendix: CI/CD Architecture Diagram

The following diagram is suitable for onboarding and presentations.

## Mermaid Diagram

```mermaid
flowchart TD
    A[GitHub Repo] -->|push / manual| B[GitHub Actions]
    B -->|self-hosted runner| C[EC2 Host]

    C --> D[repo-mirror]
    D --> E[git worktree<br/>releases/&lt;SHA&gt;]

    E --> F[Validation<br/>(dbt, dags, checks)]
    F -->|success| G[Atomic symlink switch<br/>current → &lt;SHA&gt;]

    G --> H[Production Runtime<br/>(Airflow, dbt)]
    G --> I[Docs Publish Workflow]

    I --> J[Published Docs]

    F -->|failure| K[Deploy stops<br/>current unchanged]
```

## ASCII Diagram (quick reference)

```
GitHub Repo
    |
    v
GitHub Actions
(self-hosted runner)
    |
    v
EC2 Host
    |
    +--> repo-mirror
    |
    +--> releases/<SHA>
            |
            v
        validation
            |
            v
     symlink flip (current)
            |
            +--> production runtime
            |
            +--> docs publish
```

---

## Final Operational Rule

> If `current` did not change, **nothing was deployed**.
