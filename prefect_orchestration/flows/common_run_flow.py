from __future__ import annotations

from collections.abc import Mapping
import sys
from functools import partial
from pathlib import Path



UTILS_DIR = Path(__file__).resolve().parents[1] / "utils"
if str(UTILS_DIR) not in sys.path:
    sys.path.insert(0, str(UTILS_DIR))

from prefect import flow, get_run_logger, task
from prefect.states import State
from prefect.utilities.annotations import quote
from prefect.variables import Variable

from dbt_utils import run_dbt, set_loaddate
from dryrun import DryRun
from flow_utils import (
    run_sequential_tasks,
    task_dry_run,
)
from smtp_utils import send_flow_report



@flow
def common_run_flow(
    task_dry_runs: Mapping[str, DryRun] | None = None,
) -> None:

    loaddate = set_loaddate()

    task_states = {}

    tasks = [
        (
            "Common",
            partial(
                run_dbt,
                command_name="Common",
                target=Variable.get("target", default="dev"),
                run_type="Manual Prod run",
                loaddate=loaddate,
            ),
        )
    ]

    



    run_sequential_tasks(tasks, task_states, task_dry_runs)


    send_flow_report(
        task_states=quote(task_states),
        dry_run=task_dry_run("Send Flow Report", task_dry_runs),
    )


if __name__ == "__main__":
    state = common_run_flow(
        task_dry_runs={
            "Common": DryRun.REAL,
            "Send Flow Report": DryRun.REAL,
        },
        return_state=True,
    )

    print(state)
