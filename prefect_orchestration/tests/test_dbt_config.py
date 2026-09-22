"""Smoke test for dbt configuration.

Purpose:
    Verify that the environment provides the minimum dbt project and profile
    settings required for orchestration runs.
"""

from __future__ import annotations

import sys
from pathlib import Path


UTILS_DIR = Path(__file__).resolve().parents[1] / "utils"
if str(UTILS_DIR) not in sys.path:
    sys.path.insert(0, str(UTILS_DIR))

from environment_utils import validate_dbt_config


def test_smtp_config_is_present() -> None:
    """Assert that the dbt project configuration is available."""
    ok, message = validate_dbt_config()

    assert ok, message
