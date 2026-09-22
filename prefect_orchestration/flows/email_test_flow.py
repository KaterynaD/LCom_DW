"""Send a validation email through Prefect.

Purpose:
    Provide a small operational flow that confirms SMTP configuration and email
    delivery wiring without running the full dbt orchestration.

Production notes:
    Update ``EMAIL_TO`` or move it to configuration before relying on this flow
    as part of an operational runbook.
"""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Final


UTILS_DIR = Path(__file__).resolve().parents[1] / "utils"
if str(UTILS_DIR) not in sys.path:
    sys.path.insert(0, str(UTILS_DIR))

from prefect import flow, get_run_logger, task

from smtp_utils import send_email


# Populate manually for this test.
EMAIL_TO: Final[str] = "kdrogaieva@learning.com"


@task
def send_test_email() -> None:
    """Send a one-off SMTP validation email through a Prefect task."""
    logger = get_run_logger()

    send_email(
        email_to=EMAIL_TO,
        subject="Prefect test email",
        body=(
            "This is a test email sent from a Prefect workflow.\n\n"
            "The SMTP configuration was loaded successfully."
        ),
    )

    logger.info("Test email sent to %s", EMAIL_TO)


@flow(name="send-test-email")
def send_test_email_flow() -> None:
    """Run the lightweight email validation flow."""
    send_test_email()


if __name__ == "__main__":
    send_test_email_flow()
