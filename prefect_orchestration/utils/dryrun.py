"""Dry-run primitives for deterministic flow testing.

Purpose:
    Model success and failure Prefect states without executing the real side
    effects, which keeps tests and local validation fast and predictable.
"""

from __future__ import annotations

from enum import Enum
from typing import Any

from prefect.states import Completed, Failed, State


class DryRun(str, Enum):
    """Control whether a task performs real work or returns a simulated state."""

    REAL = "real"
    PASS = "pass"
    FAIL = "fail"


def simulate(
    dry_run: DryRun,
    message: str,
) -> State[Any] | None:
    """
    REAL:
        Return None so the task performs its real operation.

    PASS:
        Simulate a successful Prefect task state.

    FAIL:
        Simulate a failed Prefect task state without raising
        a Python exception and producing a traceback.
    """
    if dry_run == DryRun.REAL:
        return None

    if dry_run == DryRun.PASS:
        return Completed(
            name="DryRunPassed",
            message=f"[DRY RUN PASS] {message}",
        )

    if dry_run == DryRun.FAIL:
        return Failed(
            name="DryRunFailed",
            message=f"[DRY RUN FAIL] {message}",
        )

    raise ValueError(f"Unsupported DryRun value: {dry_run!r}")
