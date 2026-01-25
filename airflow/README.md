# LCom DW — Airflow DAGs (Scheduled + Manual Maintenance) & Utilities

This directory contains **production-grade Airflow DAGs** and **shared utilities** used to orchestrate dbt-based data warehouse loads for Learning.com (LCom DW).

Design goals:
- Reusable initialization logic (optional `git pull` + `dbt deps`)
- Consistent per-task failure notifications
- Safe operational maintenance workflows (FK drop/restore, snapshots, tests)
- Standard end-of-run summary email for every pipeline

---

## 📁 Files Overview

### Shared utility module

| File | Type | Description |
|---|---|---|
| `dag_utils.py` | Utility module | Shared configuration, init branching, callbacks, and email notifications |

### Scheduled production DAGs

| File | DAG ID | Purpose |
|---|---|---|
| `0_lcom_dw_scheduled_product_usage_run_dag.py` | `0_lcom_dw_scheduled_product_usage_scheduled_run` | Scheduled **Product Usage** dbt run + test |
| `0_lcom_dw_scheduled_full_run_dag.py` | `0_lcom_dw_full_scheduled_run` | Scheduled **full LCom DW production load** (common + domains + snapshots + tests) |

### Manual maintenance DAGs (manual trigger only)

| File | DAG ID | Purpose |
|---|---|---|
| `1_lcom_dw_manual_dropping_fk_dag.py` | `1_lcom_dw_manual_dropping_fk` | `dbt run-operation Dropping_all_FK` |
| `2_lcom_dw_manual_run_common_dag.py` | `2_lcom_dw_manual_run_common` | `dbt run --select tag:common` |
| `3_1_lcom_dw_manual_run_licensing_dag.py` | `3_1_lcom_dw_manual_run_licensing` | `dbt run --select tag:licensing` |
| `3_2_lcom_dw_manual_run_training_sessions_dag.py` | `3_2_lcom_dw_manual_run_training_sessions` | `dbt run --select tag:training` |
| `3_3_lcom_dw_manual_run_support_dag.py` | `3_3_lcom_dw_manual_run_support` | `dbt run --select tag:support` |
| `3_4_lcom_dw_manual_run_revenue_dag.py` | `3_4_lcom_dw_manual_run_revenue` | `dbt run --select tag:revenue` |
| `3_5_lcom_dw_manual_run_cdu_dag.py` | `3_5_lcom_dw_manual_run_cdu` | `dbt run --select tag:cdu` |
| `4_lcom_dw_manual_run_snapshots_dag.py` | `4_lcom_dw_manual_run_snapshots` | `dbt run --select tag:snapshot` |
| `5_lcom_dw_manual_restore_fk_dag.py` | `5_lcom_dw_manual_restore_fk` | `dbt run-operation Recreating_all_FK` |
| `6_lcom_dw_manual_full_test_dag.py` | `6_lcom_dw_manual_full_test` | `dbt test` (excludes views + product_usage) |

---

## 🔧 dag_utils.py — Shared Utilities

### Configuration sources

| Name | Source | Default | Meaning |
|---|---|---|---|
| `REPO_DIR` | env var | `/opt/airflow/transformations` | Root git repo directory (for `git pull`) |
| `DBT_LCOM_DW_PROJECT_DIR` | env var | `/opt/airflow/transformations/dbt/LCom_DW` | dbt project directory (for `dbt ...`) |
| `ALERT_EMAIL` | Airflow Variable `ALERT_EMAIL` | `reportinganalytics@learning.com` | Where failure/summary emails go |
| `INIT_DBT_PROJECT` | Airflow Variable `INIT_DBT_PROJECT` | `YES` | Controls whether init branch runs git+deps |

### Init branch (shared pattern)

All DAGs start with the same init branch built by `create_init_branch()`:

```
decide_init_dbt_project
   ├── refresh_git_repo  (git pull origin master)  -> run_dbt_deps (dbt deps)
   └── skip_dbt_init
            ↓
         init_done
```

- If `INIT_DBT_PROJECT = YES`: runs `refresh_git_repo` then `run_dbt_deps`
- If `INIT_DBT_PROJECT != YES`: safely skips both and continues

### Notifications

**Per-task failure email**
- `notify_task_failure()` sends an email on task failure
- It cleans the `task_instance.log_url` by removing `base_date` from the query string (more reliable links)

**Run summary email**
- `create_notify_summary_task()` appends a terminal task (default `notify_summary`) that emails:
  - succeeded tasks
  - failed tasks
  - other/unfinished tasks
- It excludes the summary task itself so it doesn’t show up as “unfinished” while sending the email

---

## 🟦 Scheduled DAG: Product Usage

**DAG ID:** `0_lcom_dw_scheduled_product_usage_scheduled_run`

### Flow
```
init_done
  → dbt run (tag:product_usage, exclude views)
  → dbt test (tag:product_usage)
  → notify_summary
```

### Notes
- Lightweight and safe to run independently
- No FK drop/restore
- No snapshots

---

## 🟩 Scheduled DAG: Full LCom DW Load

**DAG ID:** `0_lcom_dw_full_scheduled_run`

### What it does
A full production load with:
- Load-date generation via XCom
- Foreign key drop before core loads
- Common + domain runs (parallel)
- Core-success gate before snapshots/FK restore/tests
- Snapshots, FK recreation, tests
- Summary email at the end

### High-level flow
```
init_done
  → Start_Load.Set_Load_Date
  → Dropping_all_FK
  → dbt run (tag:common)
  → [licensing, training, support, revenue, cdu]  (parallel)
  → check_core_success
  → dbt run (tag:snapshot)
  → Recreating_all_FK
  → dbt test (exclude views + tag:product_usage)
  → notify_summary
```

### Core-success gate
`check_core_success` ensures the critical tasks are successful before allowing snapshots/FK restore/tests. If any core task fails, it raises an exception so downstream “safety” steps won’t run.

---

## 🧰 Manual Maintenance DAGs

These are **manual-trigger-only** “single-purpose” DAGs. They all follow the same structure:

```
init_done → core_task → notify_summary
```

### FK operations
- **Drop all FKs:** `1_lcom_dw_manual_dropping_fk`
- **Restore all FKs:** `5_lcom_dw_manual_restore_fk`

### Targeted domain runs
- **Common:** `2_lcom_dw_manual_run_common`
- **Licensing:** `3_1_lcom_dw_manual_run_licensing`
- **Training:** `3_2_lcom_dw_manual_run_training_sessions`
- **Support:** `3_3_lcom_dw_manual_run_support`
- **Revenue:** `3_4_lcom_dw_manual_run_revenue`
- **CDU:** `3_5_lcom_dw_manual_run_cdu`

### Snapshots and tests
- **Snapshots:** `4_lcom_dw_manual_run_snapshots`
- **Full tests:** `6_lcom_dw_manual_full_test`

---

## 📧 Email behavior (all DAGs)

| Notification | Trigger |
|---|---|
| Task failure email | Immediately on failure (per-task callback) |
| Summary email | Always (ALL_DONE) |

---

## 🏷️ Tag conventions

- Scheduled: `scheduled`, plus domain tags like `product usage`, `full_load`
- Manual: `maintenance`, plus functional tags like `fk`, `snapshots`, `test`, `revenue`, etc.

---

## ⚠️ Operational notes

- Most DAGs currently use `schedule_interval=None` (manual trigger). Convert to cron when ready.
- DAG IDs are prefixed with numbers (`0_`, `1_`, `2_`, `3_...`) to keep a predictable order in the Airflow UI.
- FK drop/restore is intentionally separated into both:
  - a full scheduled pipeline (automated) and
  - manual “maintenance” DAGs (operator-controlled)

---

**Owner:** Data Engineering / Analytics  
**Environment:** Production (EC2 + Docker Airflow)


---

## 🧪 Development & Utility DAGs

These DAGs and scripts are **non-production helpers** used for validation, testing, and development workflows. They are safe to run independently and do not modify warehouse data.

### Test Email Summary DAG

| File | DAG ID | Purpose |
|---|---|---|
| `test_email_summary_dag.py` | `test_email_summary` | Validates Airflow SMTP configuration and summary email rendering |

**Behavior**
- Sends a dummy summary email
- Always succeeds
- Useful after SMTP or email config changes

---

### Hello World Example DAG

| File | DAG ID | Purpose |
|---|---|---|
| `hello-world.py` | `hello_world_dag` | Minimal example DAG for sanity checks |

**Behavior**
- Runs a single Python task printing `Hello World!`
- Scheduled daily (`@daily`)
- Intended for learning, smoke tests, or environment verification

---

### DAG Import Validation Script

| File | Type | Purpose |
|---|---|---|
| `dev_check_dags.py` | Python script | Verifies DAG imports without starting Airflow |

**What it does**
- Loads all DAGs from `AIRFLOW__CORE__DAGS_FOLDER`
- Prints:
  - Import errors (if any)
  - Total DAG count
  - List of discovered DAG IDs

**Typical usage**
```bash
python dev_check_dags.py
```

This is especially useful in:
- CI/CD pipelines
- Local development
- Debugging broken DAG imports

---
