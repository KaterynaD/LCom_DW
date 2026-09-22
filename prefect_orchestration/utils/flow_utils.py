"""Common flow orchestration helpers.

Purpose:
    Provide reusable helpers for sequential task execution, branch-style
    parallel execution, dry-run selection, and YES/NO Prefect variable parsing.

Production notes:
    These helpers intentionally centralize failure handling so flows emit a
    consistent report before surfacing a failing task result.
"""

from __future__ import annotations

from typing import Any

from prefect.futures import wait
from prefect.states import State
from prefect.utilities.annotations import quote
from prefect.variables import Variable

from dryrun import DryRun
from smtp_utils import send_flow_report


# =================================================================================================

def run_sequential_tasks(
    tasks,
    task_states: dict,
    task_dry_runs=None,
) -> None:
    """Run tasks in order, stopping on failure after sending a flow report."""
    for task_name, task_fn, *args in tasks:
        state: State[Any] = task_fn(
            *args,
            dry_run=task_dry_run(task_name, task_dry_runs),
            return_state=True,
        )

        task_states[task_name] = state

        if not state.is_completed():
            send_flow_report(
                task_states=quote(task_states),
                dry_run=task_dry_run("Send Flow Report", task_dry_runs),
                return_state=True,
            )

            state.result()


# =================================================================================================

def run_parallel_tasks(
    parallel_tasks: list,
    task_states: dict,
    task_dry_runs=None,
) -> None:
    """
    Run independent branches in parallel.

    Each branch can be either:
      - one task: (task_name, task_submitter)
      - sequential tasks: [(task_name, task_submitter), ...]

    Tasks inside one branch are linked with wait_for, so they run sequentially.
    If a task fails, later tasks in that branch do not run. Other branches are
    independent, and this function records all states without raising an error.
    """
    futures = []

    for parallel_branch in parallel_tasks:
        if isinstance(parallel_branch, tuple):
            parallel_branch = [parallel_branch]

        previous_future = None

        for task_name, task_submitter in parallel_branch:
            if previous_future is None:
                future = task_submitter(
                    dry_run=task_dry_run(task_name, task_dry_runs),
                )
            else:
                future = task_submitter(
                    dry_run=task_dry_run(task_name, task_dry_runs),
                    wait_for=[previous_future],
                )

            futures.append((task_name, future))
            previous_future = future

    wait([future for _, future in futures])

    for task_name, future in futures:
        task_states[task_name] = future.state


# =================================================================================================

def task_dry_run(
    task_name: str,
    task_dry_runs=None,
) -> DryRun:
    """Return the dry-run mode configured for a task name."""
    if task_dry_runs is None:
        return DryRun.REAL

    return task_dry_runs.get(task_name, DryRun.REAL)


# =================================================================================================

def get_variable_as_bool(name: str, default: bool = True) -> bool:
    """
    Read a Prefect variable with values YES/NO and return a bool.

    If the variable does not exist, return the supplied default.
    Raises ValueError for any value other than YES or NO.
    """
    value = Variable.get(name, default="YES" if default else "NO")

    if not isinstance(value, str):
        raise ValueError(
            f"Prefect variable '{name}' must be 'YES' or 'NO', got {value!r}"
        )

    value = value.strip().upper()

    if value == "YES":
        return True
    if value == "NO":
        return False

    raise ValueError(
        f"Prefect variable '{name}' must be 'YES' or 'NO', got '{value}'"
    )
