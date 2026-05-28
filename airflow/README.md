# LCom DW — Airflow DAGs & Utilities

This directory contains **production-grade Airflow DAGs** and **shared utilities** for orchestrating dbt-based data warehouse loads for Learning.com (LCom DW). The architecture emphasizes modularity, reusability, and operational safety with comprehensive monitoring and notification capabilities.

---

## 🎯 Design Philosophy

### Core Principles
1. **Reusable Components**: Shared initialization logic, email notifications, and task builders reduce code duplication
2. **Modular Architecture**: Domain-specific DAGs (common, licensing, training, support, revenue, marketing, CDU) can run independently or as part of full pipeline
3. **Safe Operations**: FK constraint management, toggleable execution, and comprehensive error handling
4. **Observability**: Per-task failure alerts and comprehensive end-of-run summary emails
5. **Flexibility**: Airflow Variables control scheduling, feature toggles, and execution behavior

### Orchestration Pattern
All DAGs follow a consistent pattern:
```
Set LoadDate → Init/Setup → Core dbt Operations → Summary Notification
```

- **LoadDate**: Captured at DAG start via XCom for consistent timestamp across all tasks
- **Core Operations**: dbt run/test/snapshot/run-operation commands
- **Notifications**: Per-task failures trigger immediate alerts; end-of-run summary reports all task states

---

## 📁 Project Structure

```
airflow/
├── dags/               # Airflow DAG definitions
│   ├── 0_*.py         # Scheduled production DAGs
│   ├── 1-6_*.py       # Manual maintenance DAGs
│   ├── sfdc_*.py      # Salesforce-related DAGs
│   └── test_*.py      # Testing/validation DAGs
└── utils/              # Shared utility modules
    ├── dag_utils.py           # Core DAG utilities & callbacks
    ├── dbt_run_utils.py       # dbt task builders
    ├── colibri_lineage.py     # Column lineage analysis
    ├── set_airflow_variables.py  # Variable initialization
    └── dev_check_dags.py      # Development DAG validation
```

---

## 🔧 Utility Modules

### `dag_utils.py` — Core DAG Utilities

**Purpose**: Shared configuration, initialization patterns, callbacks, and helper functions used across all DAGs.

**Key Components**:

#### Configuration
| Variable | Source | Default | Description |
|----------|--------|---------|-------------|
| `REPO_DIR` | env var | `/opt/airflow/releases/current/transformations` | Git repository root |
| `DBT_LCOM_DW_PROJECT_DIR` | env var | `/opt/airflow/releases/current/transformations/dbt/LCom_DW` | dbt project directory |
| `DBT_PROFILES_DIR` | env var | `/home/airflow/.dbt` | dbt profiles location |
| `DBT_TARGET_DIR` | env var | `/home/airflow/dbt_target` | dbt target/compiled output |
| `ALERT_EMAIL` | Airflow Variable | `reportinganalytics@learning.com` | Notification email address |
| `INIT_DBT_PROJECT` | Airflow Variable | `NO` | Enable/disable git pull + dbt deps |

#### Initialization Pattern
`create_init_branch()` generates consistent initialization flow:
```
decide_init_dbt_project (Branch)
   ├── run_dbt_deps (if INIT_DBT_PROJECT=YES)
   └── skip_dbt_init
         ↓
    init_done (join with NONE_FAILED_MIN_ONE_SUCCESS)
```

#### Notification Functions
- **`notify_task_failure(context)`**: Per-task failure callback
  - Sends immediate email with DAG/task info and log URL
  - Cleans log URLs by removing `base_date` parameter for stable links
  
- **`create_notify_summary_task(dag, run_name)`**: End-of-run summary
  - Collects all task states (succeeded/failed/other)
  - Sends comprehensive status report
  - Uses `TriggerRule.ALL_DONE` to always execute

#### Helper Functions
- **`create_set_load_date_task(dag)`**: Captures PST timestamp in XCom for consistent loaddate
- **`create_create_connection_task(dag)`**: Creates/updates Redshift connections from dbt profiles
- **`create_profile_task(table_name, profile_name)`**: Generates SFDC table profiling tasks for schema audit

---

### `dbt_run_utils.py` — dbt Task Builders

**Purpose**: Factory functions that generate BashOperator tasks for dbt commands with consistent structure.

**Task Builders**:
- `make_run_lcom_dw_common_task()` — `dbt run --select tag:common`
- `make_run_lcom_dw_licensing_task()` — `dbt run --select tag:licensing`
- `make_run_lcom_dw_training_sessions_task()` — `dbt run --select tag:training`
- `make_run_lcom_dw_support_task()` — `dbt run --select tag:support`
- `make_run_lcom_dw_revenue_task()` — `dbt run --select tag:revenue`
- `make_run_lcom_dw_marketing_task()` — `dbt run --select tag:marketing`
- `make_run_lcom_dw_revenue_and_marketing_task()` — Combined revenue + marketing
- `make_run_lcom_dw_cdu_task()` — `dbt run --select tag:cdu`
- `make_run_lcom_dw_snapshots_task()` — `dbt run --select tag:snapshot`
- `make_run_drop_all_fk_task()` — `dbt run-operation Dropping_all_FK`
- `make_run_recreating_all_fk_task()` — `dbt run-operation Recreating_all_FK`
- `make_run_tests_task()` — `dbt test` (excludes views and product_usage)

**Common Features**:
- All tasks exclude `config.materialized:view` to avoid view-only runs
- Thread control via optional `threads` parameter
- LoadDate from XCom via Jinja templating
- `run_type` parameter for audit trail in dbt logs
- Automatic failure notification via `notify_task_failure` callback

---

### `colibri_lineage.py` — Column Lineage Analysis

**Purpose**: Library for traversing column-level lineage using Colibri manifest data.

**Main Function**: `get_column_lineage(manifest_path, source, source_column)`

**Returns**:
```python
{
  "source": "<source node>",
  "source_column": "<column name>",
  "direct_usage": ["model.project.first_model", ...],      # Immediate consumers
  "downstream_usage": ["model.project.downstream_model", ...],  # Indirect consumers
  "error": ""  # Error message if any
}
```

**Use Case**: Schema drift audit — identifies impact of missing/changed columns on downstream models.

**Algorithm**:
- Builds graph from Colibri edges (source → target with column mappings)
- BFS/DFS traversal to find all paths from source column
- Distinguishes direct usage (first model in path) vs downstream (subsequent models)
- Avoids cycles and enforces max depth limit

---

### `set_airflow_variables.py` — Variable Initialization

**Purpose**: CI/CD script to initialize required Airflow Variables with defaults.

**Variables Initialized**:

#### Scheduling
- `SCHEDULE_LCOM_DW_FULL_RUN` = `"30 1 * * *"` (1:30 AM PST)
- `SCHEDULE_LCOM_DW_PRODUCT_USAGE_RUN` = `"30 2 * * *"` (2:30 AM PST)
- `SCHEDULE_SFDC_SCHEMA_DRIFT_AUDIT` = `"0 20 * * *"` (8:00 PM PST)

#### Feature Toggles (Full Run)
- `RUN__DROP_ALL_FK` = `"YES"`
- `RUN__COMMON` = `"YES"`
- `RUN__LICENSING` = `"YES"`
- `RUN__TRAINING_SESSIONS` = `"YES"`
- `RUN__SUPPORT` = `"YES"`
- `RUN__REVENUE_MARKETING` = `"YES"`
- `RUN__CDU` = `"YES"`
- `RUN__SNAPSHOTS` = `"YES"`
- `RUN__RECREATE_ALL_FK` = `"YES"`
- `RUN__TESTS` = `"YES"`

#### Other Settings
- `RUN_COLUMN_LINEAGE_FLAG` = `"YES"` (Enable lineage in schema drift)
- `USE_EXISTING_BASE_PROFILE` = `"NO"` (Recreate base profiles)
- `ALERT_EMAIL` = `"reportinganalytics@learning.com"`
- `INIT_DBT_PROJECT` = `"NO"` (Skip git pull)

**Usage**: Run during deployment to ensure all required variables exist.

---

### `dev_check_dags.py` — Development Validation

**Purpose**: Development utility to validate DAG syntax and imports without starting Airflow scheduler.

**Functionality**:
- Loads all DAGs from configured dags folder
- Reports import errors with file paths and error messages
- Lists all successfully loaded DAG IDs
- Exit with status for CI/CD integration

**Usage**: `python utils/dev_check_dags.py`

---

## 📅 Scheduled Production DAGs

### `0_lcom_dw_scheduled_full_run_dag.py`
**DAG ID**: `0_lcom_dw_scheduled_full_run_dag`

**Purpose**: Complete nightly data warehouse refresh — runs all domains with FK management and tests.

**Schedule**: Controlled by `SCHEDULE_LCOM_DW_FULL_RUN` variable (default: 1:30 AM PST)

**Flow**:
```
Set LoadDate
    ↓
Drop All FK (toggleable via RUN__DROP_ALL_FK)
    ↓
Common (toggleable via RUN__COMMON)
    ↓
┌─────────┬──────────┬─────────┬──────────────────┬──────┐
│Licensing│ Training │ Support │ Revenue+Marketing│ CDU  │
└─────────┴──────────┴─────────┴──────────────────┴──────┘
    ↓ (snapshots_gate: only if ≥1 domain succeeded)
Snapshots (toggleable via RUN__SNAPSHOTS)
    ↓
Recreate All FK (toggleable via RUN__RECREATE_ALL_FK)
    ↓
Tests (toggleable via RUN__TESTS)
    ↓
Summary Notification
```

**Key Features**:
- **Toggle Pattern**: Each major step wrapped in `make_toggle_task_group()` allowing runtime enable/disable
- **Smart Gating**: Snapshots only run if at least one domain succeeded (prevents wasted snapshot on total failure)
- **Parallel Domains**: Licensing, training, support, revenue/marketing, and CDU run in parallel after common
- **Thread Control**: Domain-specific thread limits (1 thread per domain to prevent resource contention)

---

### `0_lcom_dw_scheduled_product_usage_run_dag.py`
**DAG ID**: `0_lcom_dw_scheduled_product_usage_scheduled_run`

**Purpose**: Lightweight scheduled refresh of product usage analytics only.

**Schedule**: Controlled by `SCHEDULE_LCOM_DW_PRODUCT_USAGE_RUN` variable (default: 2:30 AM UTC)

**Flow**:
```
Set LoadDate
    ↓
dbt run --select tag:product_usage (exclude views)
    ↓
dbt test --select tag:product_usage
    ↓
Summary Notification
```

**Rationale**: Product usage can run independently of main warehouse and doesn't require FK management.

---

## 🛠️ Manual Maintenance DAGs

All manual DAGs have `schedule=None` and require manual trigger. They provide granular control for operational maintenance and troubleshooting.

### Foreign Key Management

#### `1_lcom_dw_manual_dropping_fk_dag.py`
**DAG ID**: `1_lcom_dw_manual_dropping_fk`

**Purpose**: Drop all foreign key constraints (prerequisite for large-scale table rebuilds).

**Flow**: `Set LoadDate → dbt run-operation Dropping_all_FK → Summary`

---

#### `5_lcom_dw_manual_restore_fk_dag.py`
**DAG ID**: `5_lcom_dw_manual_restore_fk`

**Purpose**: Recreate all foreign key constraints (run after table rebuilds complete).

**Flow**: `Set LoadDate → dbt run-operation Recreating_all_FK → Summary`

---

### Domain-Specific Runs

#### `2_lcom_dw_manual_run_common_dag.py`
**DAG ID**: `2_lcom_dw_manual_run_common`

**Purpose**: Run only common schema (shared dimensions and utilities).

**Flow**: `Set LoadDate → dbt run --select tag:common → Summary`

---

#### `3_1_lcom_dw_manual_run_licensing_dag.py`
**DAG ID**: `3_1_lcom_dw_manual_run_licensing`

**Purpose**: Run only licensing domain models.

**Flow**: `Set LoadDate → dbt run --select tag:licensing → Summary`

---

#### `3_2_lcom_dw_manual_run_training_sessions_dag.py`
**DAG ID**: `3_2_lcom_dw_manual_run_training_sessions`

**Purpose**: Run only training sessions domain models.

**Flow**: `Set LoadDate → dbt run --select tag:training → Summary`

---

#### `3_3_lcom_dw_manual_run_support_dag.py`
**DAG ID**: `3_3_lcom_dw_manual_run_support`

**Purpose**: Run only support domain models.

**Flow**: `Set LoadDate → dbt run --select tag:support → Summary`

---

#### `3_4_lcom_dw_manual_run_revenue_dag.py`
**DAG ID**: `3_4_lcom_dw_manual_run_revenue`

**Purpose**: Run only revenue domain models.

**Flow**: `Set LoadDate → dbt run --select tag:revenue → Summary`

---

#### `3_4_1_lcom_dw_manual_run_marketing_dag.py`
**DAG ID**: `3_4_lcom_dw_manual_run_marketing`

**Purpose**: Run only marketing domain models.

**Flow**: `Set LoadDate → dbt run --select tag:marketing → Summary`

**Note**: Marketing was separated from revenue to allow independent execution and better resource management.

---

#### `3_5_lcom_dw_manual_run_cdu_dag.py`
**DAG ID**: `3_5_lcom_dw_manual_run_cdu`

**Purpose**: Run only CDU (Curriculum Data Updates) domain models.

**Flow**: `Set LoadDate → dbt run --select tag:cdu → Summary`

---

### Snapshots and Testing

#### `4_lcom_dw_manual_run_snapshots_dag.py`
**DAG ID**: `4_lcom_dw_manual_run_snapshots`

**Purpose**: Run dbt snapshots for slowly changing dimensions (SCD Type 2).

**Flow**: `Set LoadDate → dbt run --select tag:snapshot → Summary`

---

#### `6_lcom_dw_manual_full_test_dag.py`
**DAG ID**: `6_lcom_dw_manual_full_test`

**Purpose**: Run all dbt tests (excludes views and product_usage).

**Flow**: `Set LoadDate → dbt test → Summary`

---

## 🔍 Salesforce Schema Audit DAGs

### `sfdc_schema_drift_audit_dag.py`
**DAG ID**: `sfdc_schema_drift_audit`

**Purpose**: Automated schema drift detection for Salesforce tables — profiles current schema, compares with baseline, identifies missing and 100% empty columns, and traces downstream impact via column lineage.

**Schedule**: Controlled by `SCHEDULE_SFDC_SCHEMA_DRIFT_AUDIT` variable (default: 8:00 PM UTC)

**Flow**:
```
Set LoadDate
    ↓
Create Redshift Connections (from dbt profiles)
    ↓
Manage Base Profile (if USE_EXISTING_BASE_PROFILE=NO: delete old base, rename current→base otherwise preserve existing base profile)
    ↓
┌────────┬─────────┬──────────┬──────┬──────────┬──────────┬──────┬─────────┬──────────┐
│Account │Opportunity│Opp Line │Case  │Training  │Product_2 │User  │Contact  │Campaign  │
│Profile │Profile   │Profile   │Profile│Profile  │Profile   │Profile│Profile │Profile   │
└────────┴──────────┴──────────┴──────┴──────────┴──────────┴──────┴─────────┴──────────┘
    ↓ (require at least 1 success)
Branch on RUN_COLUMN_LINEAGE_FLAG
    ├── YES → dbt docs generate → colibri generate → Compile Analyses
    └── NO → Skip
    ↓ (join)
dbt compile
    ↓
Run Schema Drift Analysis & Send Report
    ↓
Summary Notification
```

**Key Features**:

1. **Profile Management**:
   - Creates "current" profile for 9 SFDC tables using dbt macro `create_profile`
   - Stores profiles in `rawdata.profiles.sfdc_schema_audit`
   - Optionally preserves existing "base" profile or creates new baseline

2. **Lineage Analysis** (when `RUN_COLUMN_LINEAGE_FLAG=YES`):
   - Compiles dbt project to generate manifest
   - Generates dbt docs and Colibri manifest
   - Uses `colibri_lineage.py` to trace missing column impact
   - Identifies which models directly/indirectly use missing columns
   - If a missing or empty column is used in models -> USE_EXISTING_BASE_PROFILE variable is set to YES. Base profile is not recreated automatically till all issues are resoved (no drift, empty report). It can be recreated manually if needed using **sfdc_base_profiles_manual_run** dag
   - Missing or empty columns not used in models do not impact USE_EXISTING_BASE_PROFILE variable. 
   - If no schema drift issues detected -> USE_EXISTING_BASE_PROFILE variable is set to NO.
   - Issues can be resolved by removing columns from models or by changing/reverting changes in Salesforce. In both case, finally, USE_EXISTING_BASE_PROFILE is set to NO when no missing or empty important for models columns are detected.

3. **Drift Detection**:
   - Runs compiled SQL analyses: `profiles_stats.sql` and `missing_columns_lineage.sql`
   - Compares base vs current profile column counts
   - Lists specific columns added/removed

4. **Email Report**:
   - Profile statistics table (column count changes highlighted)
   - Missing columns analysis with lineage tracing
   - Direct usage models and downstream impact models
   - HTML formatted with styling

**Variables**:
- `USE_EXISTING_BASE_PROFILE` = `"YES"` (preserve base) / `"NO"` (recreate baseline)
- `RUN_COLUMN_LINEAGE_FLAG` = `"YES"` (full lineage) / `"NO"` (basic drift only)

---

### `sfdc_base_profiles_manual_run_dag.py`
**DAG ID**: `sfdc_base_profiles_manual_run`

**Purpose**: Create baseline "base" profiles for all 9 SFDC tables (used as comparison baseline for drift detection).

**Flow**:
```
Init Branch (optional git pull + dbt deps)
    ↓
Set LoadDate
    ↓
┌────────┬─────────┬──────────┬──────┐
│Account │Opportunity│Opp Line │Case  │
│Profile │Profile   │Profile   │Profile│
└────────┴──────────┴──────────┴──────┘
    ↓
┌──────────┬──────────┬──────┐
│Training  │Product_2 │User  │
│Profile   │Profile   │Profile│
└──────────┴──────────┴──────┘
    ↓
┌─────────┬──────────┐
│Contact  │Campaign  │
│Profile  │Profile   │
└─────────┴──────────┘
    ↓
Summary Notification
```

**Use Case**: Run once to establish baseline, or after major SFDC schema changes to reset baseline.

---

## 🧪 Testing DAGs

### `test_email_summary_dag.py`
**DAG ID**: `test_email_summary`

**Purpose**: Simple test DAG to validate SMTP email configuration.

**Flow**: Single task that sends test summary email

**Use Case**: Verify email notifications work before deploying production DAGs.

---

## 🚀 Deployment & Operations

### Initial Setup
1. Deploy Airflow environment with required connections (Redshift, SMTP)
2. Set dbt profiles in `DBT_PROFILES_DIR` (`/home/airflow/.dbt/profiles.yml`)
3. Run `set_airflow_variables.py` to initialize variables
4. Validate DAGs: `python utils/dev_check_dags.py`

### Daily Operations
- **Scheduled**: Full run at 1:30 AM PST, Product Usage at 2:30 AM PST, Schema Audit at 8:00 PM PST
- **Manual Triggers**: Use maintenance DAGs for targeted operations (FK drop/restore, domain-specific runs, tests)
- **Monitoring**: Check email alerts for failures, review summary emails for run status

### Troubleshooting
1. **DAG Import Errors**: Run `dev_check_dags.py` to identify syntax/import issues
2. **Task Failures**: Check per-task failure email with log URL
3. **Incomplete Runs**: Review summary email for task states (succeeded/failed/other)
4. **Schema Drift**: Review schema audit report for missing columns and lineage impact

### Customization
- **Adjust Schedules**: Modify `SCHEDULE_*` variables in Airflow UI
- **Toggle Execution**: Set `RUN__*` variables to `YES`/`NO` for selective execution in full run
- **Change Recipients**: Update `ALERT_EMAIL` variable
- **Thread Control**: Modify `threads` parameter in task builder calls

---



## 📝 Change Log

### Recent Additions (Not Previously Documented)
- **Marketing Separation** (`3_4_1_lcom_dw_manual_run_marketing_dag.py`): Marketing split from revenue for independent execution
- **Column Lineage** (`colibri_lineage.py`): Added comprehensive column-level lineage analysis for schema drift
- **Toggle Pattern** (Full Run): All major steps in full run now toggleable via Airflow Variables
- **Smart Gating**: Snapshots only run if at least one domain succeeded in full run
- **Enhanced Notifications**: Log URL cleaning for stable links in failure emails
- **SFDC Schema Audit**: Complete schema drift detection with lineage tracing and impact analysis

---

## 🤝 Contributing

When adding new DAGs:
1. Follow naming convention: `[priority]_[domain]_[type]_[action]_dag.py`
2. Use shared utilities from `dag_utils.py` and `dbt_run_utils.py`
3. Include LoadDate capture and summary notification
4. Add appropriate tags and description
5. Document in this README
6. Test with `dev_check_dags.py`

---

## 📧 Support

For issues or questions:
- **Email**: reportinganalytics@learning.com
- **Failed DAGs**: Check email alerts with log URLs
- **Schema Changes**: Review schema drift audit reports
