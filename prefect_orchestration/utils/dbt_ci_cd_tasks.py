"""dbt task definitions for CI/CD workflows."""

from __future__ import annotations

from environment_utils import get_required_env


PROD_STATE_DIR = get_required_env("PROD_STATE_DIR")


DBT_CI_CD_TASKS: dict[str, list[str]] = {
    "Dependencies": [
        "deps",
    ],
    "Compile": [
        "compile",
    ],
    "List Modified Objects": [
        "list",
        "--quiet",
        "--select",
        "state:modified",
        "--state",
        PROD_STATE_DIR,
        "--resource-type",
        "model",
        "test",
        "seed",
    ],
    "Drop QA Schemas": [
        "run-operation",
        "drop_qa_schemas",
        "--vars",
        '{"dry_run": false}',
    ],
    "Set QA Environment": [
        "run-operation",
        "set_QA_environment",
    ],
    "QA Seeds": [
        "seed",
    ],
    "QA Pre Deploy": [
        "run",
        "--select",
        "state:modified,deployment_pre_tasks",
        "--state",
        PROD_STATE_DIR,
        "--defer",
        "--vars",
        '{"deploy_flag": true}',
    ],
    "QA Modified Models": [
        "run",
        "--select",
        "state:modified+",
        "--exclude",
        "path:models/profiles",
        "tag:no_ci_cd",
        "--empty",
        "--state",
        PROD_STATE_DIR,
        "--defer",
        "--fail-fast",
        "--vars",
        '{"deploy_flag": true}',
    ],
    "QA Post Deploy": [
        "run",
        "--select",
        "state:modified,deployment_post_tasks",
        "--state",
        PROD_STATE_DIR,
        "--defer",
        "--vars",
        '{"deploy_flag": true}',
    ],
    "Prod Pre Deploy": [
        "run",
        "--select",
        "state:modified,deployment_pre_tasks",
        "--state",
        PROD_STATE_DIR,
        "--vars",
        '{"deploy_flag": true}',
    ],
    "Prod Modified Models": [
        "run",
        "--select",
        "state:modified",
        "--exclude",
        "path:models/profiles",
        "tag:no_ci_cd",
        "--state",
        PROD_STATE_DIR,
        "--vars",
        '{"deploy_flag": true}',
    ],
    "Prod Post Deploy": [
        "run",
        "--select",
        "state:modified,deployment_post_tasks",
        "--state",
        PROD_STATE_DIR,
        "--vars",
        '{"deploy_flag": true}',
    ],
    "Prod Tests": [
        "test",
        "--select",
        "state:modified+",
        "--exclude",
        "path:models/profiles",
        "tag:no_ci_cd",
        "--state",
        PROD_STATE_DIR,
        "--vars",
        '{"deploy_flag": true}',
    ],
    "Generate Docs": [
        "docs",
        "generate",
        "--static",
    ],
}
