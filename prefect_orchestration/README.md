# Prefect Orchestration

Simple dbt orchestration framework built with Prefect.

This package provides a lightweight structure for running dbt marts, validating runtime configuration, managing Prefect variables, and sending email notifications for task/flow outcomes.

## What this project does

- Runs dbt marts through Prefect tasks and flows.
- Supports sequential and parallel orchestration patterns.
- Provides dry-run simulation modes for safer local testing.
- Sends flow and task status notifications via SMTP.
- Validates required dbt and SMTP configuration before execution.
- Includes a CI/CD-style flow that runs setup and smoke checks in sequence.

## Available functionality

### Flows

- `flows/dbt_marts_run.py`
  - Main orchestration flow for dbt marts.
  - Mix of sequential + parallel branches.
- `flows/email_test_flow.py`
  - Utility flow to validate SMTP email delivery.
- `flows/prefect_ci_cd_flow.py`
  - Sequential CI/CD readiness flow:
    1. set default Prefect variables
    2. run dbt config smoke test
    3. run SMTP config smoke test

### Utilities

- `utils/dbt_utils.py`
  - dbt command mapping and task execution (`PrefectDbtRunner`).
- `utils/flow_utils.py`
  - Shared orchestration helpers (`run_sequential_tasks`, `run_parallel_tasks`, dry-run lookup).
- `utils/dryrun.py`
  - Dry-run behavior (`REAL`, `PASS`, `FAIL`) and state simulation.
- `utils/environment_utils.py`
  - `.env` loading, path resolution, and dbt/SMTP config validation.
- `utils/smtp_utils.py`
  - Email sending plus task/flow notification helpers.
- `utils/set_default_prefect_variables.py`
  - Bootstraps default Prefect variables used by flows.
- `utils/generate_flow_diagram.py`
  - Generates Mermaid flow diagrams from flow source code.

### Tests

- `tests/test_dbt_marts_run.py`
  - Behavioral tests for orchestration flow outcomes.
- `tests/test_dbt_config.py`
  - Smoke test for required dbt config.
- `tests/test_smtp_config.py`
  - Smoke test for required SMTP config.

## Project structure

```text
prefect_orchestration/
  README.md
  __init__.py
  flows/
    dbt_marts_run.py
    dbt_marts_run.md
    email_test_flow.py
    prefect_ci_cd_flow.py
  utils/
    dbt_utils.py
    dryrun.py
    environment_utils.py
    flow_utils.py
    generate_flow_diagram.py
    set_default_prefect_variables.py
    smtp_utils.py
  tests/
    test_dbt_config.py
    test_dbt_marts_run.py
    test_smtp_config.py
```

## Runtime prerequisites

- Python environment with project dependencies installed.
- Prefect workspace access (for variables and orchestration runs).
- dbt project and profile paths configured via environment variables.
- SMTP settings configured for notifications.

## Typical usage

- Run main orchestration flow: `flows/dbt_marts_run.py`
- Run readiness checks: `flows/prefect_ci_cd_flow.py`
- Run test email flow: `flows/email_test_flow.py`
- Run tests: `pytest prefect_orchestration/tests -q`

## Notes

- The framework favors explicit, composable utility modules over large monolithic flow files.
- Dry-run support makes it easy to validate orchestration behavior without executing real side effects.

## Venv setup (Prefect only)

```text
pip install dbt-colibri
pip install dbt-core==1.12.0 dbt-redshift

pip install pytest
pip install prefect prefect_dbt
pip install prefect_sqlalchemy
pip install sqlalchemy-redshift psycopg2-binary
```
