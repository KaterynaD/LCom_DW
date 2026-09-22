"""Smoke test for SMTP configuration.

Purpose:
    Verify that email-related environment settings are present and usable before
    runtime notifications are needed by production flows.
"""

from __future__ import annotations

import sys
from pathlib import Path


UTILS_DIR = Path(__file__).resolve().parents[1] / "utils"
if str(UTILS_DIR) not in sys.path:
    sys.path.insert(0, str(UTILS_DIR))

from environment_utils import validate_smtp_config


def test_smtp_config_is_present() -> None:
    """Assert that SMTP configuration is available for notifications."""
    ok, message = validate_smtp_config()

    assert ok, message
