"""Sequential Prefect CI/CD flow for baseline project checks."""

from __future__ import annotations

import sys
from pathlib import Path
from functools import partial
from typing import Any
import shutil

PACKAGE_DIR = Path(__file__).resolve().parents[1]
UTILS_DIR = PACKAGE_DIR / "utils"
TESTS_DIR = PACKAGE_DIR / "tests"

for path in [str(UTILS_DIR), str(TESTS_DIR)]:
    if path not in sys.path:
        sys.path.insert(0, path)


from prefect import flow, get_run_logger, task
from prefect.states import State
from prefect.task_runners import ProcessPoolTaskRunner
from prefect.utilities.annotations import quote
from prefect.variables import Variable

from dbt_utils import run_dbt, set_loaddate
from dryrun import DryRun, simulate
from flow_utils import (
    get_variable_as_bool,
    run_sequential_tasks,
    task_dry_run,
)
from set_default_prefect_variables import set_default_prefect_variables
from smtp_utils import send_flow_report, send_task_failure_email
from test_dbt_config import test_smtp_config_is_present as run_dbt_config_test
from test_smtp_config import test_smtp_config_is_present as run_smtp_config_test
from environment_utils import get_env_path

DBT_TARGET_PATH = get_env_path("DBT_TARGET_PATH")
PROD_STATE_DIR = get_env_path("PROD_STATE_DIR")


@task(
    task_run_name="Save CURRENT Prod manifest",
    on_failure=[send_task_failure_email],
)
def save_current_prod_manifest(
    dry_run: DryRun = DryRun.REAL,
) -> State[Any] | None:
    """Save the CURRENT Prod dbt manifest for state comparison."""

    state = simulate(dry_run, "Save CURRENT Prod manifest")

    if state is not None:
        return state

    logger = get_run_logger()

    source_manifest = Path(DBT_TARGET_PATH) / "manifest.json"
    target_manifest = Path(PROD_STATE_DIR) / "manifest.json"

    if not source_manifest.is_file():
        raise FileNotFoundError(
            f"CURRENT Prod manifest not found: {source_manifest}"
        )

    logger.info(f"Saving CURRENT Prod manifest: {target_manifest}")

    shutil.copy2(source_manifest, target_manifest)

    logger.info("CURRENT Prod manifest saved successfully")

@task(on_failure=[send_task_failure_email])
def set_default_variables_task(dry_run: DryRun = DryRun.REAL):
    state = simulate(dry_run, "Set Default Prefect Variables")
    if state is not None:
        return state

    set_default_prefect_variables()


@task(on_failure=[send_task_failure_email])
def dbt_config_test_task(dry_run: DryRun = DryRun.REAL):
    state = simulate(dry_run, "Run test_dbt_config")
    if state is not None:
        return state

    run_dbt_config_test()


@task(on_failure=[send_task_failure_email])
def smtp_config_test_task(dry_run: DryRun = DryRun.REAL):
    state = simulate(dry_run, "Run test_smtp_config")
    if state is not None:
        return state

    run_smtp_config_test()


@flow(name="ci_cd_flow_1_prepare_validate_current")
def ci_cd_flow_1_prepare_validate_current(task_dry_runs=None) -> None:
    task_states = {}

    loaddate = '1900-01-01'

    tasks = [
        ("Set Default Prefect Variables", set_default_variables_task),
        ("Test SMTP config", smtp_config_test_task),
        ("Test dbt config", dbt_config_test_task),
        (
                    "Compile CURRENT Prod release",
                    partial(
                        run_dbt.submit,
                        command_name="Compile",
                        dbt_run_as=  'shell',
                        target=Variable.get("target", default="dev"),
                        run_type= "CI/CD run",
                        loaddate=loaddate
                    ),
        ),      
        ("Save CURRENT Prod manifest", partial(save_current_prod_manifest)),
        
    ]

    run_sequential_tasks(tasks, task_states, task_dry_runs)

    send_flow_report(
        task_states=quote(task_states),
        dry_run=task_dry_run("Send Flow Report", task_dry_runs),
    )


if __name__ == "__main__":
    state = ci_cd_flow_1_prepare_validate_current(
        task_dry_runs={
            "Set Default Prefect Variables": DryRun.REAL,
            "Test dbt config": DryRun.REAL,
            "Test SMTP config": DryRun.REAL,
            "Compile CURRENT Prod release": DryRun.REAL,
            "Save CURRENT Prod manifest": DryRun.REAL,
            "Send Flow Report": DryRun.REAL,
        },
        return_state=True,
    )

    print(state)

    if state.is_failed():
        sys.exit(1)

    sys.exit(0)
