"""SMTP-backed notification helpers for Prefect tasks and flows.

Purpose:
    Encapsulate email delivery, task failure alerts, and end-of-flow reporting so
    notification behavior stays consistent across orchestration modules.

Production notes:
    - requires SMTP environment variables and a password file;
    - uses Prefect runtime metadata to include task and flow links in messages;
    - supports dry-run simulation for safe local verification.
"""

from __future__ import annotations

import smtplib
from collections.abc import Sequence
from email.message import EmailMessage
from typing import Any

from prefect import task
from prefect.client.schemas.objects import TaskRun
from prefect.logging.loggers import task_run_logger
from prefect.runtime import flow_run
from prefect.states import State
from prefect.tasks import Task
from prefect.utilities.urls import url_for
from prefect.variables import Variable

from dryrun import DryRun, simulate
from environment_utils import get_required_env, get_smtp_password

EMAIL_TO = Variable.get("alert_email", default="kdrogaieva@learning.com")


# =============================================================================================

def send_email(
    *,
    email_to: str | Sequence[str] = EMAIL_TO,
    subject: str,
    body: str,
    html_content: str | None = None,
    dry_run: DryRun = DryRun.REAL,
) -> State[Any] | None:
    """
    Send an email through SMTP using STARTTLS.
    """
    state = simulate(dry_run, "Send Email")

    if state is not None:
        return state

    smtp_host = get_required_env("SMTP_HOST")
    smtp_port = int(get_required_env("SMTP_PORT"))
    smtp_user = get_required_env("SMTP_USER")
    smtp_from = get_required_env("SMTP_FROM")
    smtp_password = get_smtp_password()

    if isinstance(email_to, str):
        recipients = [email_to]
    else:
        recipients = email_to

    if not recipients:
        raise ValueError("At least one email recipient is required.")

    message = EmailMessage()
    message["From"] = smtp_from
    message["To"] = ", ".join(recipients)
    message["Subject"] = subject

    message.set_content(body)

    if html_content is not None:
        message.add_alternative(
            html_content,
            subtype="html",
        )

    with smtplib.SMTP(
        host=smtp_host,
        port=smtp_port,
        timeout=60,
    ) as smtp:
        smtp.ehlo()
        smtp.starttls()
        smtp.ehlo()
        smtp.login(smtp_user, smtp_password)
        smtp.send_message(message)


# =============================================================================================

def send_task_failure_email(
    task: Task,
    task_run: TaskRun,
    state: State,
) -> None:
    """Send a notification email for a failed Prefect task run."""
    if state.name == "DryRunFailed":
        return

    logger = task_run_logger(task_run, task)

    task_run_url = url_for(task_run)

    subject = f"Prefect task failed: {task_run.name}"

    body = f"""
Prefect task failed.

Task: {task.name}
Task run: {task_run.name}
State: {state.name}
Error: {state.message or "No error message available"}

Task logs:
{task_run_url or "Prefect UI URL is not configured"}
""".strip()

    html_content = f"""
<html>
<body>
    <h3>Prefect task failed</h3>

    <p>
        <strong>Task:</strong> {task.name}<br>
        <strong>Task run:</strong> {task_run.name}<br>
        <strong>State:</strong> {state.name}<br>
        <strong>Error:</strong> {state.message or "No error message available"}
    </p>

    <p>
        <strong>Task logs:</strong><br>
        <a href="{task_run_url}">{task_run_url}</a>
    </p>
</body>
</html>
""".strip()

    try:
        send_email(
            email_to=EMAIL_TO,
            subject=subject,
            body=body,
            html_content=html_content,
        )
    except Exception:
        logger.exception(
            "Could not send failure email for task %s",
            task_run.name,
        )


# =============================================================================================
@task(name="send_flow_report")
def send_flow_report(
    *,
    task_states: dict[str, State[Any]],
    dry_run: DryRun = DryRun.REAL,
) -> State[Any] | None:
    """Send a summary email describing the final state of flow tasks."""
    state = simulate(dry_run, "Send Flow Report")

    if state is not None:
        return state

    flow_name = flow_run.flow_name
    flow_run_name = flow_run.name
    flow_run_id = flow_run.id

    flow_run_url = url_for(
        "flow-run",
        obj_id=flow_run_id,
    )

    report_lines = []
    html_report_lines = []
    has_failures = False

    for task_name, state in task_states.items():
        if state.is_completed():
            status = "COMPLETE"
        elif state.is_failed():
            status = "FAIL"
            has_failures = True
        else:
            status = state.name.upper()

        report_lines.append(f"{task_name}: {status}")
        html_report_lines.append(
            f"<div><strong>{task_name}:</strong> {status}</div>"
        )

    overall_status = (
        "COMPLETED WITH TASK FAILURES"
        if has_failures
        else "COMPLETE"
    )

    body = f"""
Prefect flow report

Flow: {flow_name}
Flow run: {flow_run_name}
Status: {overall_status}

Tasks:
{chr(10).join(report_lines)}

Flow logs:
{flow_run_url or "Prefect UI URL is not configured"}
""".strip()

    html_content = f"""
<html>
<body>
    <h3>Prefect flow report</h3>

    <p>
        <strong>Flow:</strong> {flow_name}<br>
        <strong>Flow run:</strong> {flow_run_name}<br>
        <strong>Status:</strong> {overall_status}
    </p>

    <p><strong>Tasks:</strong></p>

    {"".join(html_report_lines)}

    <p>
        <strong>Flow logs:</strong><br>
        <a href="{flow_run_url}">{flow_run_url}</a>
    </p>
</body>
</html>
""".strip()

    send_email(
        email_to=EMAIL_TO,
        subject=f"Prefect flow {overall_status}: {flow_name}",
        body=body,
        html_content=html_content,
    )