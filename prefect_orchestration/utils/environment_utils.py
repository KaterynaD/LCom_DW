"""Environment loading and configuration validation helpers.

Purpose:
    Load ``.env`` values, resolve project-relative paths, read secret files, and
    validate the minimum SMTP and dbt configuration required by the flows.

Production notes:
    Keep secrets out of source control and supply them through environment
    variables or files referenced by environment variables.
"""

from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv


PROJECT_DIR = Path(__file__).resolve().parents[2]
_ENV_LOADED = False


def _ensure_environment_loaded() -> None:
    """Load the environment once before any configuration lookup occurs."""
    global _ENV_LOADED
    if not _ENV_LOADED:
        load_environment()
        _ENV_LOADED = True


def load_environment(
    *,
    project_dir: Path = PROJECT_DIR,
    env_file_name: str = ".env",
    override: bool = False,
) -> Path:
    """
    Load environment variables from a dotenv file.

    Returns the resolved path to the dotenv file that was targeted.
    """
    global _ENV_LOADED

    env_path = project_dir / env_file_name
    load_dotenv(dotenv_path=env_path, override=override)
    _ENV_LOADED = True
    return env_path


def get_required_env(
    name: str,
) -> str:
    """
    Read a required environment variable.

    Raises RuntimeError when the variable is missing or blank.
    """
    _ensure_environment_loaded()

    value = os.getenv(name)

    if value is None or not value.strip():
        raise RuntimeError(
            f"Required setting is missing: {name}"
        )

    return value


def get_env_path(
    name: str,
    *,
    project_dir: Path = PROJECT_DIR,
) -> Path:
    """
    Read a path-valued environment variable.

    - Expands '~'.
    - Resolves relative paths against project_dir.
    """
    path_value = get_required_env(name)
    path = Path(path_value).expanduser()

    if not path.is_absolute():
        path = project_dir / path

    return path


def get_smtp_password(
    *,
    project_dir: Path = PROJECT_DIR,
) -> str:
    """
    Read SMTP password from file path declared in SMTP_PASSWORD_FILE.

    SMTP_PASSWORD_FILE may be absolute or relative to project_dir.
    """
    password_file = get_env_path(
        "SMTP_PASSWORD_FILE",
        project_dir=project_dir,
    )

    if not password_file.is_file():
        raise FileNotFoundError(
            f"SMTP password file was not found: {password_file}"
        )

    password = password_file.read_text(encoding="utf-8").strip()
    if not password:
        raise RuntimeError(
            f"SMTP password file is empty: {password_file}"
        )

    return password


def validate_smtp_config(
    *,
    project_dir: Path = PROJECT_DIR,
) -> tuple[bool, str]:
    """
    Validate SMTP-related environment settings.

    Specific checks retained for SMTP:
    - required settings exist;
    - SMTP_PORT is an integer in [1, 65535];
    - SMTP_PASSWORD_FILE exists and is non-empty.
    """
    try:
        smtp_host = get_required_env("SMTP_HOST")
        smtp_port_raw = get_required_env("SMTP_PORT")
        smtp_user = get_required_env("SMTP_USER")
        smtp_from = get_required_env("SMTP_FROM")
        smtp_password = get_smtp_password(project_dir=project_dir)
    except Exception as exc:
        return False, str(exc)

    if not smtp_host:
        return False, "SMTP_HOST is empty."

    if not smtp_user:
        return False, "SMTP_USER is empty."

    if not smtp_from:
        return False, "SMTP_FROM is empty."

    try:
        smtp_port = int(smtp_port_raw)
    except ValueError:
        return False, f"SMTP_PORT is not a valid integer: {smtp_port_raw}"

    if not (1 <= smtp_port <= 65535):
        return False, (
            f"SMTP_PORT must be between 1 and 65535, received {smtp_port}."
        )

    if not smtp_password:
        return False, "SMTP password is empty."

    return True, ""


def validate_dbt_config(
    *,
    project_dir: Path = PROJECT_DIR,
) -> tuple[bool, str]:
    """
    Validate dbt-related environment settings.

    Specific checks retained for dbt:
    - DBT_LCOM_DW_PROJECT_DIR exists and is a directory;
    - DBT_TARGET_PATH exists and is a directory;
    - PROD_STATE_DIR exists and is a directory;
    - DBT_PROFILES_DIR exists and is a directory;
    - dbt_project.yml exists in project dir;
    - profiles.yml exists in profiles dir.
    """
    try:
        dbt_project_dir = get_env_path(
            "DBT_LCOM_DW_PROJECT_DIR",
            project_dir=project_dir,
        )
        DBT_TARGET_PATH = get_env_path(
            "DBT_TARGET_PATH",
            project_dir=project_dir,
        )
        prod_state_dir = get_env_path(
            "PROD_STATE_DIR",
            project_dir=project_dir,
        )
        dbt_profiles_dir = get_env_path(
            "DBT_PROFILES_DIR",
            project_dir=project_dir,
        )
    except Exception as exc:
        return False, str(exc)

    if not dbt_project_dir.is_dir():
        return False, (
            "DBT_LCOM_DW_PROJECT_DIR does not exist "
            f"or is not a directory: {dbt_project_dir}"
        )

    if not DBT_TARGET_PATH.is_dir():
        return False, (
            "DBT_TARGET_PATH does not exist "
            f"or is not a directory: {DBT_TARGET_PATH}"
        )

    if not prod_state_dir.is_dir():
        return False, (
            "PROD_STATE_DIR does not exist "
            f"or is not a directory: {prod_state_dir}"
        )


    if not dbt_profiles_dir.is_dir():
        return False, (
            "DBT_PROFILES_DIR does not exist "
            f"or is not a directory: {dbt_profiles_dir}"
        )

    dbt_project_file = dbt_project_dir / "dbt_project.yml"
    if not dbt_project_file.is_file():
        return False, f"dbt_project.yml was not found: {dbt_project_file}"

    profiles_file = dbt_profiles_dir / "profiles.yml"
    if not profiles_file.is_file():
        return False, f"profiles.yml was not found: {profiles_file}"

    return True, ""
