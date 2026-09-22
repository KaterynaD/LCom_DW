"""Behavioral tests for the CI/CD validation and deployment flow.

Purpose:
    Confirm that the orchestration completes when all dry-run tasks pass and
    fails when critical validation or deployment tasks are simulated to fail.
"""

from __future__ import annotations

import sys
from pathlib import Path
from unittest.mock import patch


PACKAGE_DIR = Path(__file__).resolve().parents[1]
FLOWS_DIR = PACKAGE_DIR / "flows"
UTILS_DIR = PACKAGE_DIR / "utils"

for path in [str(FLOWS_DIR), str(UTILS_DIR)]:
    if path not in sys.path:
        sys.path.insert(0, path)

from ci_cd_flow_2_validate_deploy_new import ci_cd_flow_2_validate_deploy_new
from dryrun import DryRun


@patch(
    "ci_cd_flow_2_validate_deploy_new.get_variable_as_bool",
    return_value=True,
)
def test_all_tasks_pass_flow_completes(_get_variable_as_bool) -> None:
    """Ensure the happy path completes when every task is simulated to pass."""
    state = ci_cd_flow_2_validate_deploy_new(
        task_dry_runs={
            "dbt Dependencies": DryRun.PASS,
            "Compile NEW Prod release": DryRun.PASS,
            "List Modified Objects": DryRun.PASS,
            "Clean up QA environment": DryRun.PASS,
            "Set QA Environment": DryRun.PASS,
            "QA Seeds": DryRun.PASS,
            "QA Pre Deploy": DryRun.PASS,
            "QA Modified Models": DryRun.PASS,
            "QA Post Deploy": DryRun.PASS,
            "Prod Pre Deploy": DryRun.PASS,
            "Prod Modified Models": DryRun.PASS,
            "Prod Post Deploy": DryRun.PASS,
            "Prod Tests": DryRun.PASS,
            "Generate dbt Docs": DryRun.PASS,
            "Generate Colibri Lineage": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_completed()


@patch(
    "ci_cd_flow_2_validate_deploy_new.get_variable_as_bool",
    return_value=True,
)
def test_compile_new_prod_release_fail_flow_fails(
    _get_variable_as_bool,
) -> None:
    """Ensure the flow fails when compilation is simulated to fail."""
    state = ci_cd_flow_2_validate_deploy_new(
        task_dry_runs={
            "dbt Dependencies": DryRun.PASS,
            "Compile NEW Prod release": DryRun.FAIL,
            "List Modified Objects": DryRun.PASS,
            "Clean up QA environment": DryRun.PASS,
            "Set QA Environment": DryRun.PASS,
            "QA Seeds": DryRun.PASS,
            "QA Pre Deploy": DryRun.PASS,
            "QA Modified Models": DryRun.PASS,
            "QA Post Deploy": DryRun.PASS,
            "Prod Pre Deploy": DryRun.PASS,
            "Prod Modified Models": DryRun.PASS,
            "Prod Post Deploy": DryRun.PASS,
            "Prod Tests": DryRun.PASS,
            "Generate dbt Docs": DryRun.PASS,
            "Generate Colibri Lineage": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_failed()


@patch(
    "ci_cd_flow_2_validate_deploy_new.get_variable_as_bool",
    return_value=True,
)
def test_list_modified_objects_fail_flow_fails(
    _get_variable_as_bool,
) -> None:
    """Ensure the flow fails when listing modified objects fails."""
    state = ci_cd_flow_2_validate_deploy_new(
        task_dry_runs={
            "dbt Dependencies": DryRun.PASS,
            "Compile NEW Prod release": DryRun.PASS,
            "List Modified Objects": DryRun.FAIL,
            "Clean up QA environment": DryRun.PASS,
            "Set QA Environment": DryRun.PASS,
            "QA Seeds": DryRun.PASS,
            "QA Pre Deploy": DryRun.PASS,
            "QA Modified Models": DryRun.PASS,
            "QA Post Deploy": DryRun.PASS,
            "Prod Pre Deploy": DryRun.PASS,
            "Prod Modified Models": DryRun.PASS,
            "Prod Post Deploy": DryRun.PASS,
            "Prod Tests": DryRun.PASS,
            "Generate dbt Docs": DryRun.PASS,
            "Generate Colibri Lineage": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_failed()


@patch(
    "ci_cd_flow_2_validate_deploy_new.get_variable_as_bool",
    return_value=True,
)
def test_qa_modified_models_fail_flow_fails_when_qa_tests_enabled(
    _get_variable_as_bool,
) -> None:
    """Ensure the flow fails when QA modified models fail."""
    state = ci_cd_flow_2_validate_deploy_new(
        task_dry_runs={
            "dbt Dependencies": DryRun.PASS,
            "Compile NEW Prod release": DryRun.PASS,
            "List Modified Objects": DryRun.PASS,
            "Clean up QA environment": DryRun.PASS,
            "Set QA Environment": DryRun.PASS,
            "QA Seeds": DryRun.PASS,
            "QA Pre Deploy": DryRun.PASS,
            "QA Modified Models": DryRun.FAIL,
            "QA Post Deploy": DryRun.PASS,
            "Prod Pre Deploy": DryRun.PASS,
            "Prod Modified Models": DryRun.PASS,
            "Prod Post Deploy": DryRun.PASS,
            "Prod Tests": DryRun.PASS,
            "Generate dbt Docs": DryRun.PASS,
            "Generate Colibri Lineage": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_failed()


@patch(
    "ci_cd_flow_2_validate_deploy_new.get_variable_as_bool",
    side_effect=lambda name, default=True: name != "run__qa_tests",
)
def test_qa_modified_models_fail_flow_completes_when_qa_tests_disabled(
    _get_variable_as_bool,
) -> None:
    """Ensure a disabled QA branch ignores its simulated task failure."""
    state = ci_cd_flow_2_validate_deploy_new(
        task_dry_runs={
            "dbt Dependencies": DryRun.PASS,
            "Compile NEW Prod release": DryRun.PASS,
            "List Modified Objects": DryRun.PASS,
            "Clean up QA environment": DryRun.PASS,
            "Set QA Environment": DryRun.PASS,
            "QA Seeds": DryRun.PASS,
            "QA Pre Deploy": DryRun.PASS,
            "QA Modified Models": DryRun.FAIL,
            "QA Post Deploy": DryRun.PASS,
            "Prod Pre Deploy": DryRun.PASS,
            "Prod Modified Models": DryRun.PASS,
            "Prod Post Deploy": DryRun.PASS,
            "Prod Tests": DryRun.PASS,
            "Generate dbt Docs": DryRun.PASS,
            "Generate Colibri Lineage": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_completed()


@patch(
    "ci_cd_flow_2_validate_deploy_new.get_variable_as_bool",
    return_value=True,
)
def test_prod_modified_models_fail_flow_fails_when_prod_deployment_enabled(
    _get_variable_as_bool,
) -> None:
    """Ensure the flow fails when production modified models fail."""
    state = ci_cd_flow_2_validate_deploy_new(
        task_dry_runs={
            "dbt Dependencies": DryRun.PASS,
            "Compile NEW Prod release": DryRun.PASS,
            "List Modified Objects": DryRun.PASS,
            "Clean up QA environment": DryRun.PASS,
            "Set QA Environment": DryRun.PASS,
            "QA Seeds": DryRun.PASS,
            "QA Pre Deploy": DryRun.PASS,
            "QA Modified Models": DryRun.PASS,
            "QA Post Deploy": DryRun.PASS,
            "Prod Pre Deploy": DryRun.PASS,
            "Prod Modified Models": DryRun.FAIL,
            "Prod Post Deploy": DryRun.PASS,
            "Prod Tests": DryRun.PASS,
            "Generate dbt Docs": DryRun.PASS,
            "Generate Colibri Lineage": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_failed()


@patch(
    "ci_cd_flow_2_validate_deploy_new.get_variable_as_bool",
    side_effect=lambda name, default=True: name != "run__prod_deployment",
)
def test_prod_modified_models_fail_flow_completes_when_prod_deployment_disabled(
    _get_variable_as_bool,
) -> None:
    """Ensure a disabled production branch ignores its simulated model failure."""
    state = ci_cd_flow_2_validate_deploy_new(
        task_dry_runs={
            "dbt Dependencies": DryRun.PASS,
            "Compile NEW Prod release": DryRun.PASS,
            "List Modified Objects": DryRun.PASS,
            "Clean up QA environment": DryRun.PASS,
            "Set QA Environment": DryRun.PASS,
            "QA Seeds": DryRun.PASS,
            "QA Pre Deploy": DryRun.PASS,
            "QA Modified Models": DryRun.PASS,
            "QA Post Deploy": DryRun.PASS,
            "Prod Pre Deploy": DryRun.PASS,
            "Prod Modified Models": DryRun.FAIL,
            "Prod Post Deploy": DryRun.PASS,
            "Prod Tests": DryRun.PASS,
            "Generate dbt Docs": DryRun.PASS,
            "Generate Colibri Lineage": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_completed()


@patch(
    "ci_cd_flow_2_validate_deploy_new.get_variable_as_bool",
    return_value=True,
)
def test_prod_tests_fail_flow_fails_when_prod_deployment_enabled(
    _get_variable_as_bool,
) -> None:
    """Ensure the flow fails when production tests fail."""
    state = ci_cd_flow_2_validate_deploy_new(
        task_dry_runs={
            "dbt Dependencies": DryRun.PASS,
            "Compile NEW Prod release": DryRun.PASS,
            "List Modified Objects": DryRun.PASS,
            "Clean up QA environment": DryRun.PASS,
            "Set QA Environment": DryRun.PASS,
            "QA Seeds": DryRun.PASS,
            "QA Pre Deploy": DryRun.PASS,
            "QA Modified Models": DryRun.PASS,
            "QA Post Deploy": DryRun.PASS,
            "Prod Pre Deploy": DryRun.PASS,
            "Prod Modified Models": DryRun.PASS,
            "Prod Post Deploy": DryRun.PASS,
            "Prod Tests": DryRun.FAIL,
            "Generate dbt Docs": DryRun.PASS,
            "Generate Colibri Lineage": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_failed()


@patch(
    "ci_cd_flow_2_validate_deploy_new.get_variable_as_bool",
    side_effect=lambda name, default=True: name != "run__prod_deployment",
)
def test_prod_tests_fail_flow_completes_when_prod_deployment_disabled(
    _get_variable_as_bool,
) -> None:
    """Ensure a disabled production branch ignores its simulated test failure."""
    state = ci_cd_flow_2_validate_deploy_new(
        task_dry_runs={
            "dbt Dependencies": DryRun.PASS,
            "Compile NEW Prod release": DryRun.PASS,
            "List Modified Objects": DryRun.PASS,
            "Clean up QA environment": DryRun.PASS,
            "Set QA Environment": DryRun.PASS,
            "QA Seeds": DryRun.PASS,
            "QA Pre Deploy": DryRun.PASS,
            "QA Modified Models": DryRun.PASS,
            "QA Post Deploy": DryRun.PASS,
            "Prod Pre Deploy": DryRun.PASS,
            "Prod Modified Models": DryRun.PASS,
            "Prod Post Deploy": DryRun.PASS,
            "Prod Tests": DryRun.FAIL,
            "Generate dbt Docs": DryRun.PASS,
            "Generate Colibri Lineage": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_completed()


@patch(
    "ci_cd_flow_2_validate_deploy_new.get_variable_as_bool",
    return_value=True,
)
def test_generate_dbt_docs_fail_flow_fails(
    _get_variable_as_bool,
) -> None:
    """Ensure the flow fails when dbt documentation generation fails."""
    state = ci_cd_flow_2_validate_deploy_new(
        task_dry_runs={
            "dbt Dependencies": DryRun.PASS,
            "Compile NEW Prod release": DryRun.PASS,
            "List Modified Objects": DryRun.PASS,
            "Clean up QA environment": DryRun.PASS,
            "Set QA Environment": DryRun.PASS,
            "QA Seeds": DryRun.PASS,
            "QA Pre Deploy": DryRun.PASS,
            "QA Modified Models": DryRun.PASS,
            "QA Post Deploy": DryRun.PASS,
            "Prod Pre Deploy": DryRun.PASS,
            "Prod Modified Models": DryRun.PASS,
            "Prod Post Deploy": DryRun.PASS,
            "Prod Tests": DryRun.PASS,
            "Generate dbt Docs": DryRun.FAIL,
            "Generate Colibri Lineage": DryRun.PASS,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_failed()


@patch(
    "ci_cd_flow_2_validate_deploy_new.get_variable_as_bool",
    return_value=True,
)
def test_generate_colibri_lineage_fail_flow_fails(
    _get_variable_as_bool,
) -> None:
    """Ensure the flow fails when Colibri lineage generation fails."""
    state = ci_cd_flow_2_validate_deploy_new(
        task_dry_runs={
            "dbt Dependencies": DryRun.PASS,
            "Compile NEW Prod release": DryRun.PASS,
            "List Modified Objects": DryRun.PASS,
            "Clean up QA environment": DryRun.PASS,
            "Set QA Environment": DryRun.PASS,
            "QA Seeds": DryRun.PASS,
            "QA Pre Deploy": DryRun.PASS,
            "QA Modified Models": DryRun.PASS,
            "QA Post Deploy": DryRun.PASS,
            "Prod Pre Deploy": DryRun.PASS,
            "Prod Modified Models": DryRun.PASS,
            "Prod Post Deploy": DryRun.PASS,
            "Prod Tests": DryRun.PASS,
            "Generate dbt Docs": DryRun.PASS,
            "Generate Colibri Lineage": DryRun.FAIL,
            "Send Flow Report": DryRun.PASS,
        },
        return_state=True,
    )

    assert state.is_failed()
