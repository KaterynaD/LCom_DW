"""Shared dbt execution helpers for Prefect tasks.

Purpose:
    Centralize dbt command selection, runtime argument assembly, and Prefect dbt
    task execution so flows can stay focused on orchestration.

Production notes:
    - requires ``DBT_LCOM_DW_PROJECT_DIR`` and ``DBT_PROFILES_DIR``;
    - wraps dbt calls with Prefect task metadata and failure notification hooks;
    - supports dry-run and variable-controlled task skipping.
"""

from __future__ import annotations

import json
from datetime import datetime
import os
from typing import Any
from zoneinfo import ZoneInfo

from prefect import get_run_logger, task
from prefect.states import Completed
from prefect_dbt import PrefectDbtRunner, PrefectDbtSettings
from prefect_dbt import PrefectDbtSettings
from prefect_dbt.core._orchestrator import (
    PrefectDbtOrchestrator,
    ExecutionMode,
    TestStrategy,
)
import subprocess

from dbt_ci_cd_tasks import DBT_CI_CD_TASKS
from dbt_core_dw_tasks import DBT_CORE_DW_TASKS
from dbt_sfdc_profile_tasks import DBT_SFDC_PROFILE_TASKS



from dryrun import DryRun, simulate
from environment_utils import get_env_path
from smtp_utils import send_task_failure_email


DBT_TASKS: dict[str, list[str]] = {
    **DBT_CORE_DW_TASKS,
    **DBT_SFDC_PROFILE_TASKS,
    **DBT_CI_CD_TASKS,
}


DBT_LCOM_DW_PROJECT_DIR = get_env_path("DBT_LCOM_DW_PROJECT_DIR")
DBT_PROFILES_DIR = get_env_path("DBT_PROFILES_DIR")
DBT_TARGET_PATH = get_env_path("DBT_TARGET_PATH")


def set_loaddate() -> str:
    """Return the load date timestamp in the expected warehouse timezone."""
    return (
        datetime.now(ZoneInfo("America/Los_Angeles"))
        .replace(microsecond=0)
        .isoformat()
    )


def get_dbt_command(command_name: str) -> list[str]:
    """Return a copy of the dbt CLI arguments for a named mart command."""
    return DBT_TASKS[command_name].copy()


@task(
    task_run_name="{command_name}",
    on_failure=[send_task_failure_email],
)
def run_dbt(
    command_name: str,
    dbt_run_as =  'prefect',
    threads: int | None = None,
    target: str | None = None,
    loaddate: str | None = None,
    run_type: str = "Scheduled Prod run",
    run_enabled: bool = True,
    dry_run: DryRun = DryRun.REAL,
) -> Any:
    """Execute or simulate a dbt command within a Prefect task.

    Returns the simulated Prefect state for dry runs, a skipped state when the
    task is disabled, or the underlying dbt invocation result for real runs.
    """
    dbt_args = get_dbt_command(command_name)

    if threads is not None:
        dbt_args.extend([
            "--threads",
            str(threads),
        ])

    if target is not None:
        dbt_args.extend([
            "--target",
            target,
        ])

        dbt_vars = {
            "run_type": run_type,
        }

        if "--vars" in dbt_args:
            vars_index = dbt_args.index("--vars") + 1
            configured_vars = json.loads(dbt_args[vars_index])
            dbt_vars.update(configured_vars)
            dbt_args[vars_index] = json.dumps(dbt_vars)
        else:
            vars_index = None

        if loaddate is not None:
            dbt_vars["loaddate"] = loaddate

        if vars_index is not None:
            dbt_args[vars_index] = json.dumps(dbt_vars)
        else:
            dbt_args.extend([
                "--vars",
                json.dumps(dbt_vars),
            ])

    display_command = "dbt " + " ".join(dbt_args)

    state = simulate(dry_run, f"Run dbt command '{display_command}'")
    if state is not None:
        return state

    logger = get_run_logger()

    if not run_enabled:
        return Completed(
            name="Skipped",
            message=f"Task '{command_name}' is disabled by Prefect variable.",
        )

    logger.info(display_command)

    if dbt_run_as == 'prefect':
        runner = PrefectDbtRunner(
            settings=PrefectDbtSettings(
                project_dir=DBT_LCOM_DW_PROJECT_DIR,
                profiles_dir=DBT_PROFILES_DIR,
            )
        )
        return runner.invoke(dbt_args)
    elif dbt_run_as == 'orchestrator':
        orchestrator = PrefectDbtOrchestrator(
            settings=PrefectDbtSettings(
                project_dir=DBT_LCOM_DW_PROJECT_DIR,
                profiles_dir=DBT_PROFILES_DIR,
            ),
            execution_mode=ExecutionMode.PER_NODE,
            threads=threads,
            test_strategy=TestStrategy.SKIP,
        )

        select = None
        exclude = None

        if "--select" in dbt_args:
            select_index = dbt_args.index("--select") + 1
            select = dbt_args[select_index]

        if "--exclude" in dbt_args:
            exclude_index = dbt_args.index("--exclude") + 1
            exclude = dbt_args[exclude_index]

        extra_cli_args = []

        if "--vars" in dbt_args:
            vars_index = dbt_args.index("--vars") + 1
            extra_cli_args.extend([
                "--vars",
                dbt_args[vars_index],
            ])

        return orchestrator.run_build(
            select=select,
            exclude=exclude,
            target=target,
            extra_cli_args=extra_cli_args,
        )

    else:
        process = subprocess.Popen(
            ["dbt", *dbt_args],
            cwd=DBT_LCOM_DW_PROJECT_DIR,
            env={
                **os.environ,
                "DBT_PROFILES_DIR": str(DBT_PROFILES_DIR),
            },
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )

        if process.stdout is not None:
            for line in process.stdout:
                logger.info(line.rstrip())

        return_code = process.wait()

        if return_code != 0:
            raise RuntimeError(
                f"dbt command failed with return code {return_code}"
            )

# ------------------------------------------------------------------------
# Get compiled SQL path
# ------------------------------------------------------------------------

def get_compiled_sql_sfdc_schema_drift_path(filename: str) -> str:
    """Get the path to the compiled SQL file."""
    return os.path.join(
        DBT_TARGET_PATH,
        "compiled",
        "LCom_DW",
        "analyses",
        "SFDC_schema_drift",
        filename,
    )
