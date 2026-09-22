"""dbt task definitions for core data warehouse workflows."""

from __future__ import annotations


DBT_CORE_DW_TASKS: dict[str, list[str]] = {
    "Common": [
        "run",
        "--select",
        "tag:common",
        "--exclude",
        "config.materialized:view",
    ],
    "Licensing": [
        "run",
        "--select",
        "tag:licensing",
        "--exclude",
        "config.materialized:view",
    ],
    "Training Sessions": [
        "run",
        "--select",
        "tag:training",
        "--exclude",
        "config.materialized:view",
    ],
    "Support": [
        "run",
        "--select",
        "tag:support",
        "--exclude",
        "config.materialized:view",
    ],
    "Revenue": [
        "run",
        "--select",
        "tag:revenue",
        "--exclude",
        "config.materialized:view",
    ],
    "CDU": [
        "run",
        "--select",
        "tag:cdu",
        "--exclude",
        "config.materialized:view",
    ],
    "Marketing": [
        "run",
        "--select",
        "tag:marketing",
        "--exclude",
        "config.materialized:view",
    ],
    "Drop All FK": [
        "run-operation",
        "Dropping_all_FK",
    ],
    "Recreate All FK": [
        "run-operation",
        "Recreating_all_FK",
    ],
    "Tests": [
        "test",
        "--exclude",
        "tag:product_usage",
        "test_type:unit",
    ],
    "Product Usage": [
        "run",
        "--select",
        "tag:product_usage",
        "--exclude",
        "config.materialized:view",
    ],
    "Product Usage Tests": [
        "test",
        "--select",
        "tag:product_usage",
    ],
}
