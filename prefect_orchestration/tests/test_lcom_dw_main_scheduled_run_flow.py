"""Behavioral tests for the main scheduled dbt warehouse flow.

Purpose:
    Confirm that the orchestration reacts correctly to dry-run success and
    failure states across sequential and parallel branches.
"""

from __future__ import annotations

import sys
from pathlib import Path


PACKAGE_DIR = Path(__file__).resolve().parents[1]
FLOWS_DIR = PACKAGE_DIR / "flows"
UTILS_DIR = PACKAGE_DIR / "utils"

for path in [str(FLOWS_DIR), str(UTILS_DIR)]:
    if path not in sys.path:
        sys.path.insert(0, path)

from lcom_dw_main_scheduled_run_flow import lcom_dw_main_scheduled_run_flow
from dryrun import DryRun


def test_all_tasks_pass_flow_completes() -> None:
    """Ensure the happy path completes when every task is simulated to pass."""
    state = lcom_dw_main_scheduled_run_flow(
        task_dry_runs={
            "Drop All FK": DryRun.PASS,
            "Common": DryRun.PASS,
            "CDU": DryRun.PASS,
            "Licensing": DryRun.PASS,
            "Revenue": DryRun.PASS,
            "Marketing": DryRun.PASS,
            "Training Sessions": DryRun.PASS,
            "Support": DryRun.PASS,
            "Recreate All FK": DryRun.PASS,
            "Tests": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_completed()


def test_common_fail_flow_fails() -> None:
    """Ensure the flow fails when the common task is simulated as failed."""
    state = lcom_dw_main_scheduled_run_flow(
        task_dry_runs={
            "Drop All FK": DryRun.PASS,
            "Common": DryRun.FAIL,
            "CDU": DryRun.PASS,
            "Licensing": DryRun.PASS,
            "Revenue": DryRun.PASS,
            "Marketing": DryRun.PASS,
            "Training Sessions": DryRun.PASS,
            "Support": DryRun.PASS,
            "Recreate All FK": DryRun.PASS,
            "Tests": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_failed()


def test_drop_all_fk_fail_flow_fails() -> None:
    """Ensure the flow fails when the drop all FK task is simulated as failed."""
    state = lcom_dw_main_scheduled_run_flow(
        task_dry_runs={
            "Drop All FK": DryRun.FAIL,
            "Common": DryRun.PASS,
            "CDU": DryRun.PASS,
            "Licensing": DryRun.PASS,
            "Revenue": DryRun.PASS,
            "Marketing": DryRun.PASS,
            "Training Sessions": DryRun.PASS,
            "Support": DryRun.PASS,
            "Recreate All FK": DryRun.PASS,
            "Tests": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_failed()


def test_tests_fail_flow_fails() -> None:
    """Ensure the flow fails when the tests task is simulated as failed."""
    state = lcom_dw_main_scheduled_run_flow(
        task_dry_runs={
            "Drop All FK": DryRun.PASS,
            "Common": DryRun.PASS,
            "CDU": DryRun.PASS,
            "Licensing": DryRun.PASS,
            "Revenue": DryRun.PASS,
            "Marketing": DryRun.PASS,
            "Training Sessions": DryRun.PASS,
            "Support": DryRun.PASS,
            "Recreate All FK": DryRun.PASS,
            "Tests": DryRun.FAIL,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_failed()


def test_cdu_fail_flow_completes() -> None:
    """Ensure a CDU branch failure still yields a completed flow state."""
    state = lcom_dw_main_scheduled_run_flow(
        task_dry_runs={
            "Drop All FK": DryRun.PASS,
            "Common": DryRun.PASS,
            "CDU": DryRun.FAIL,
            "Licensing": DryRun.PASS,
            "Revenue": DryRun.PASS,
            "Marketing": DryRun.PASS,
            "Training Sessions": DryRun.PASS,
            "Support": DryRun.PASS,
            "Recreate All FK": DryRun.PASS,
            "Tests": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_completed()


def test_licensing_fail_flow_completes() -> None:
    """Ensure a licensing branch failure still yields a completed flow state."""
    state = lcom_dw_main_scheduled_run_flow(
        task_dry_runs={
            "Drop All FK": DryRun.PASS,
            "Common": DryRun.PASS,
            "CDU": DryRun.PASS,
            "Licensing": DryRun.FAIL,
            "Revenue": DryRun.PASS,
            "Marketing": DryRun.PASS,
            "Training Sessions": DryRun.PASS,
            "Support": DryRun.PASS,
            "Recreate All FK": DryRun.PASS,
            "Tests": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_completed()


def test_revenue_fail_flow_completes() -> None:
    """Ensure a revenue branch failure still yields a completed flow state."""
    state = lcom_dw_main_scheduled_run_flow(
        task_dry_runs={
            "Drop All FK": DryRun.PASS,
            "Common": DryRun.PASS,
            "CDU": DryRun.PASS,
            "Licensing": DryRun.PASS,
            "Revenue": DryRun.FAIL,
            "Marketing": DryRun.PASS,
            "Training Sessions": DryRun.PASS,
            "Support": DryRun.PASS,
            "Recreate All FK": DryRun.PASS,
            "Tests": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_completed()


def test_marketing_fail_flow_completes() -> None:
    """Ensure a marketing branch failure still yields a completed flow state."""
    state = lcom_dw_main_scheduled_run_flow(
        task_dry_runs={
            "Drop All FK": DryRun.PASS,
            "Common": DryRun.PASS,
            "CDU": DryRun.PASS,
            "Licensing": DryRun.PASS,
            "Revenue": DryRun.PASS,
            "Marketing": DryRun.FAIL,
            "Training Sessions": DryRun.PASS,
            "Support": DryRun.PASS,
            "Recreate All FK": DryRun.PASS,
            "Tests": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_completed()


def test_training_sessions_fail_flow_completes() -> None:
    """Ensure a training sessions branch failure still yields a completed flow state."""
    state = lcom_dw_main_scheduled_run_flow(
        task_dry_runs={
            "Drop All FK": DryRun.PASS,
            "Common": DryRun.PASS,
            "CDU": DryRun.PASS,
            "Licensing": DryRun.PASS,
            "Revenue": DryRun.PASS,
            "Marketing": DryRun.PASS,
            "Training Sessions": DryRun.FAIL,
            "Support": DryRun.PASS,
            "Recreate All FK": DryRun.PASS,
            "Tests": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_completed()


def test_support_fail_flow_completes() -> None:
    """Ensure a support branch failure still yields a completed flow state."""
    state = lcom_dw_main_scheduled_run_flow(
        task_dry_runs={
            "Drop All FK": DryRun.PASS,
            "Common": DryRun.PASS,
            "CDU": DryRun.PASS,
            "Licensing": DryRun.PASS,
            "Revenue": DryRun.PASS,
            "Marketing": DryRun.PASS,
            "Training Sessions": DryRun.PASS,
            "Support": DryRun.FAIL,
            "Recreate All FK": DryRun.PASS,
            "Tests": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_completed()
