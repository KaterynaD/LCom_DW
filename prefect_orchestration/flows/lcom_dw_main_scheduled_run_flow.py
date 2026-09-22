"""Run the main dbt mart orchestration flow.

Purpose:
    Coordinate the warehouse mart build in a controlled Prefect flow that mixes
    sequential and parallel task execution.

Production notes:
    - imports the installed ``prefect`` package plus sibling utilities;
    - expects Prefect variables and environment settings to be configured;
    - sends flow and task failure notifications through ``smtp_utils``;
    - supports dry-run execution for safe validation in non-production runs.
    - create diagram of the flow using: 
    python .\\generate_flow_diagram.py --source ..\\flows\\lcom_dw_main_scheduled_run_flow.py --flow lcom_dw_main_scheduled_run_flow --output ..\\flows\\lcom_dw_main_scheduled_run_flow_new.md
"""

from __future__ import annotations

from collections.abc import Mapping
import sys
from functools import partial
from pathlib import Path
from typing import Any


UTILS_DIR = Path(__file__).resolve().parents[1] / "utils"
if str(UTILS_DIR) not in sys.path:
    sys.path.insert(0, str(UTILS_DIR))

from prefect import flow, get_run_logger, task
from prefect.states import State
from prefect.task_runners import ProcessPoolTaskRunner
from prefect.utilities.annotations import quote
from prefect.variables import Variable

from dbt_utils import run_dbt, set_loaddate
from dryrun import DryRun, simulate
from flow_utils import (
    get_variable_as_bool,
    run_parallel_tasks,
    run_sequential_tasks,
    task_dry_run,
)
from smtp_utils import send_flow_report, send_task_failure_email


@task
def dummy_task(dry_run: DryRun = DryRun.REAL) -> State[Any] | None:

    logger = get_run_logger()
    logger.info("=============================================")


# ProcessPoolTaskRunner is required because concurrent PrefectDbtRunner
# dbt tasks must run in separate processes. Concurrent in-process dbt runs
# complete successfully, but the flow fails during final cleanup.
@flow(task_runner=ProcessPoolTaskRunner(max_workers=20))
def lcom_dw_main_scheduled_run_flow(
    task_dry_runs: Mapping[str, DryRun] | None = None,
) -> None:
    """Run the full mart build orchestration.

    The flow executes setup work, launches independent dbt branches in parallel,
    waits for completion, and then sends a summary report.
    """
    loaddate = set_loaddate()

    task_states = {}

    starting_tasks = [
        (
            "Drop All FK",
            partial(
                run_dbt,
                command_name="Drop All FK",
                target=Variable.get("target", default="dev"),
                run_enabled=get_variable_as_bool("run__drop_all_fk", default=False),
            ),
        ),
        (
            "Common",
            partial(
                run_dbt,
                command_name="Common",
                target=Variable.get("target", default="dev"),
                loaddate=loaddate,
                run_enabled=get_variable_as_bool("run__common", default=False),
            ),
        ),
    ]

    parallel_tasks_group_1 = [
        (
            "CDU",
            partial(
                run_dbt.submit,
                command_name="CDU",
                target=Variable.get("target", default="dev"),
                threads=1,
                loaddate=loaddate,
                run_enabled=get_variable_as_bool("run__cdu", default=False),
            ),
        ),
        (
                    "Licensing",
                    partial(
                        run_dbt.submit,
                        command_name="Licensing",
                        target=Variable.get("target", default="dev"),
                        threads=1,
                        loaddate=loaddate,
                        run_enabled=get_variable_as_bool("run__licensing", default=False),
                    ),
        ),      
        [
             (
                        "Revenue",
                        partial(
                            run_dbt.submit,
                            command_name="Revenue",
                            target=Variable.get("target", default="dev"),
                            threads=1,
                            loaddate=loaddate,
                            run_enabled=get_variable_as_bool("run__revenue", default=False),
                        ),
            ),
            (
                        "Marketing",
                        partial(
                            run_dbt.submit,
                            command_name="Marketing",
                            target=Variable.get("target", default="dev"),
                            threads=1,
                            loaddate=loaddate,
                            run_enabled=get_variable_as_bool("run__marketing", default=False),
                        ),
            ),
        ],
    ]

    dummy_tasks = [("Dummy Bridge Task", dummy_task),]

    parallel_tasks_group_2 = [
            (
                        "Training Sessions",
                        partial(
                            run_dbt.submit,
                            command_name="Training Sessions",
                            target=Variable.get("target", default="dev"),
                            threads=1,
                            loaddate=loaddate,
                            run_enabled=get_variable_as_bool("run__training_sessions", default=False),
                        ),
                    ),
            (
                        "Support",
                        partial(
                            run_dbt.submit,
                            command_name="Support",
                            target=Variable.get("target", default="dev"),
                            threads=1,
                            loaddate=loaddate,
                            run_enabled=get_variable_as_bool("run__support", default=False),
                        ),
            ),    
    ]

    ending_tasks = [
        (
                    "Recreate All FK",
                    partial(
                        run_dbt,
                        command_name="Recreate All FK",
                        target=Variable.get("target", default="dev"),
                        loaddate=loaddate,
                        run_enabled=get_variable_as_bool("run__recreate_all_fk", default=False),
                    ),
        ),
        (
                    "Tests",
                    partial(
                        run_dbt,
                        command_name="Tests",
                        target=Variable.get("target", default="dev"),
                        loaddate=loaddate,
                        run_enabled=get_variable_as_bool("run__tests", default=False),
                    ),
        ),
    ]

    run_sequential_tasks(starting_tasks, task_states, task_dry_runs)
    run_parallel_tasks(parallel_tasks_group_1, task_states, task_dry_runs)
    run_sequential_tasks(dummy_tasks, task_states, task_dry_runs)
    run_parallel_tasks(parallel_tasks_group_2, task_states, task_dry_runs)
    run_sequential_tasks(ending_tasks, task_states, task_dry_runs)

    send_flow_report(
        task_states=quote(task_states),
        dry_run=task_dry_run("Send Flow Report", task_dry_runs),
    )


if __name__ == "__main__":
    state = lcom_dw_main_scheduled_run_flow(
        task_dry_runs={
            "Drop All FK": DryRun.REAL,
            "Common": DryRun.REAL,
            "CDU": DryRun.REAL,
            "Licensing": DryRun.REAL,
            "Revenue": DryRun.REAL,
            "Marketing": DryRun.REAL,
            "Training Sessions": DryRun.REAL,
            "Support": DryRun.REAL,
            "Recreate All FK": DryRun.REAL,
            "Tests": DryRun.REAL,
            "Send Flow Report": DryRun.REAL,
        },
        return_state=True,
    )

    print(state)
