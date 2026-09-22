"""Sequential Prefect CI/CD flow for baseline project checks."""

from __future__ import annotations

import os
import sys
from pathlib import Path
from functools import partial
from typing import Any
from venv import logger




PACKAGE_DIR = Path(__file__).resolve().parents[1]
UTILS_DIR = PACKAGE_DIR / "utils"
TESTS_DIR = PACKAGE_DIR / "tests"

for path in [str(UTILS_DIR), str(TESTS_DIR)]:
    if path not in sys.path:
        sys.path.insert(0, path)


from click import command
from prefect import flow, get_run_logger, task
from prefect.states import State

from prefect.utilities.annotations import quote
from prefect.variables import Variable
from prefect.states import Completed

from dbt_utils import run_dbt,get_dbt_command
from dryrun import DryRun, simulate
from flow_utils import (
    get_variable_as_bool,
    run_sequential_tasks,
    task_dry_run,
)

from smtp_utils import send_flow_report, send_task_failure_email
from environment_utils import get_env_path


DBT_LCOM_DW_PROJECT_DIR = get_env_path("DBT_LCOM_DW_PROJECT_DIR")
DBT_PROFILES_DIR = get_env_path("DBT_PROFILES_DIR")
DBT_TARGET_PATH = get_env_path("DBT_TARGET_PATH")
PROD_STATE_DIR = get_env_path("PROD_STATE_DIR")

import subprocess

# =======================================================================================================================

@task(
    task_run_name="List Modified Objects",
    on_failure=[send_task_failure_email],
)
def list_modified_objects(
    dry_run: DryRun = DryRun.REAL,
) -> list[str] | State[Any]:
    state = simulate(dry_run, "List Modified Objects")
    if state is not None:
        if state.is_failed():
            return state
        return ["dummy"]  # Indicate that the simulated dbt list found changes.

    logger = get_run_logger()

    dbt_args = get_dbt_command("List Modified Objects")

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

    modified_objects: list[str] = []

    if process.stdout is not None:
        for line in process.stdout:
            line = line.rstrip()
            logger.info(line)

            if line:
                modified_objects.append(line)

    return_code = process.wait()

    if return_code != 0:
        raise RuntimeError(
            f"dbt list failed with return code {return_code}"
        )

    return modified_objects

# =======================================================================================================================

@task(
    task_run_name="Generate Colibri Lineage",
    on_failure=[send_task_failure_email],
)
def generate_colibri_lineage(
    dry_run: DryRun = DryRun.REAL,
    run_enabled: bool = True,
) -> State[Any] | None:
    """Generate column-level lineage with Colibri."""


    logger = get_run_logger()
    logger.info("Generating Colibri lineage")

    command = [
        "colibri",
        "generate",
        "--manifest",
        str(DBT_TARGET_PATH / "manifest.json"),
        "--catalog",
        str(DBT_TARGET_PATH / "catalog.json"),
        "--output-dir",
        str(DBT_TARGET_PATH),
    ]


    display_command = " ".join(command)


    state = simulate(dry_run,f"Running command: {display_command}",)

    if state is not None:
        return state

    if not run_enabled:
        return Completed(
            name="Skipped",
            message=f"Task 'Generating Colibri lineage' is disabled by Prefect variable.",
        )


    logger.info("Running command: %s", display_command)

    process = subprocess.Popen(
    command,
    cwd=DBT_LCOM_DW_PROJECT_DIR,
    env={
        **os.environ,
        "PYTHONUTF8": "1",
        "PYTHONIOENCODING": "utf-8",
    },
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT,
    text=True,
    encoding="utf-8",
    bufsize=1,)

    if process.stdout is not None:
        for line in process.stdout:
            logger.info(line.rstrip())

    return_code = process.wait()

    if return_code != 0:
        raise RuntimeError(
            f"Colibri generate failed with return code {return_code}"
        )

    logger.info("Colibri lineage generated successfully")

# =======================================================================================================================

@flow(name="ci_cd_flow_2_validate_deploy_new")
def ci_cd_flow_2_validate_deploy_new(task_dry_runs=None) -> None:
    task_states = {}

    loaddate = '1900-01-01'

    tasks = [
        (
                    "dbt Dependencies",
                    partial(
                        run_dbt.submit,
                        command_name="Dependencies",
                        dbt_run_as=  'shell',
                        target=Variable.get("target", default="dev")
                    ),
        ),      
        (
                    "Compile NEW Prod release",
                    partial(
                        run_dbt.submit,
                        command_name="Compile",
                        dbt_run_as=  'shell',
                        target=Variable.get("target", default="dev"),
                        run_type= "CI/CD run",
                        loaddate=loaddate
                    ),
        ),      
        
    ]

    qa_tests_tasks = [
        (
            "Clean up QA environment",
            partial(
                run_dbt.submit,
                command_name="Drop QA Schemas",
                dbt_run_as='shell',
                target=Variable.get("target_qa", default="QA"),
                run_type="CI/CD run",
                loaddate=loaddate
            ),
        ),
        (
            "Set QA Environment",
            partial(
                run_dbt.submit,
                command_name="Set QA Environment",
                dbt_run_as='shell',
                target=Variable.get("target_qa", default="QA"),
                run_type="CI/CD run",
                loaddate=loaddate
            ),
        ),
        (
            "QA Seeds",
            partial(
                run_dbt.submit,
                command_name="QA Seeds",
                target=Variable.get("target_qa", default="QA"),
                run_type="CI/CD run",
                loaddate=loaddate
            ),
        ),        
        (
            "QA Pre Deploy",
            partial(
                run_dbt.submit,
                command_name="QA Pre Deploy",
                target=Variable.get("target_qa", default="QA"),
                run_type="CI/CD run",
                loaddate=loaddate
            ),
        ),      
        (
            "QA Modified Models",
            partial(
                run_dbt.submit,
                command_name="QA Modified Models",
                target=Variable.get("target_qa", default="QA"),
                run_type="CI/CD run",
                loaddate=loaddate
            ),
        ),       
        (
            "QA Post Deploy",
            partial(
                run_dbt.submit,
                command_name="QA Post Deploy",
                target=Variable.get("target_qa", default="QA"),
                run_type="CI/CD run",
                loaddate=loaddate
            ),
        ),                    
    ]

    prod_deployment_tasks = [
        (
                    "Prod Pre Deploy",
                    partial(
                        run_dbt.submit,
                        command_name="Prod Pre Deploy",
                        target=Variable.get("target", default="dev"),
                        run_type="CI/CD run",
                        loaddate=loaddate
                    ),
                ),      
        (
            "Prod Modified Models",
            partial(
                run_dbt.submit,
                command_name="Prod Modified Models",
                target=Variable.get("target", default="dev"),
                run_type="CI/CD run",
                loaddate=loaddate
            ),
        ),       
        (
            "Prod Post Deploy",
            partial(
                run_dbt.submit,
                command_name="Prod Post Deploy",
                target=Variable.get("target", default="dev"),
                run_type="CI/CD run",
                loaddate=loaddate
            ),
        ),       
        (
            "Prod Tests",
            partial(
                run_dbt.submit,
                command_name="Prod Tests",
                target=Variable.get("target", default="dev"),
                run_type="CI/CD run",
                loaddate=loaddate
            ),
        ),

    ]

    post_deployment_tasks = [
    (
        "Generate dbt Docs",
        partial(
            run_dbt.submit,
            command_name="Generate Docs",
            dbt_run_as="shell",
            target=Variable.get("target", default="dev"),
            run_type="CI/CD run",
            loaddate=loaddate,
            run_enabled=get_variable_as_bool("run__generate_dbt_docs", default=False),
        ),
    ),
    (
        "Generate Colibri Lineage",
        partial(
            generate_colibri_lineage,
            run_enabled=get_variable_as_bool(
                "run__colibri_lineage",
                default=False,
            ),
        ),
    ),
 ]

    run_sequential_tasks(tasks, task_states, task_dry_runs)

    modified_objects = list_modified_objects(
    dry_run=task_dry_run("List Modified Objects", task_dry_runs),
)

    logger = get_run_logger()

    if modified_objects:
        logger.info(
        "Found %d modified dbt object(s):\n%s",
        len(modified_objects),
        "\n".join(f"  - {obj}" for obj in modified_objects),
    )
    else:
        logger.info("No modified dbt objects in this release.")

    if modified_objects and get_variable_as_bool("run__qa_tests", default=False):
        run_sequential_tasks(qa_tests_tasks, task_states, task_dry_runs)
    else:
        logger.info("Skipping QA tests as there are no modified objects or the run__qa_tests variable is set to No.")

    if modified_objects and get_variable_as_bool("run__prod_deployment", default=False):
        run_sequential_tasks(prod_deployment_tasks, task_states, task_dry_runs)
    else:
        logger.info("Skipping Prod deployment as there are no modified objects or the run__prod_deployment variable is set to No.")

    run_sequential_tasks(post_deployment_tasks, task_states, task_dry_runs)

    send_flow_report(
        task_states=quote(task_states),
        dry_run=task_dry_run("Send Flow Report", task_dry_runs),
    )


if __name__ == "__main__":
    state = ci_cd_flow_2_validate_deploy_new(
        task_dry_runs={
            "dbt Dependencies": DryRun.REAL,
            "Compile NEW Prod release": DryRun.REAL,
            "List Modified Objects": DryRun.REAL,
            "Clean up QA environment": DryRun.REAL,
            "Set QA Environment": DryRun.REAL,
            "QA Seeds": DryRun.REAL,
            "QA Pre Deploy": DryRun.REAL,
            "QA Modified Models": DryRun.REAL,
            "QA Post Deploy": DryRun.REAL,
            "Prod Pre Deploy": DryRun.REAL,
            "Prod Modified Models": DryRun.REAL,
            "Prod Post Deploy": DryRun.REAL,
            "Prod Tests": DryRun.REAL,
            "Generate dbt Docs": DryRun.REAL,
            "Generate Colibri Lineage": DryRun.REAL,
            "Send Flow Report": DryRun.REAL,
        },
        return_state=True,
    )

    print(state)

    if state.is_failed():
        sys.exit(1)

    sys.exit(0)
