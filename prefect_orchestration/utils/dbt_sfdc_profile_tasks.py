"""dbt task definitions for Salesforce profile workflows."""

from __future__ import annotations


DBT_SFDC_PROFILE_TASKS: dict[str, list[str]] = {
    "Delete Base Profile": [
        "run-operation",
        "delete_base_profile",
    ],
    "Reset Profiles Current to Base": [
        "run-operation",
        "reset_profiles_current_to_base",
    ],
    "SFDC Schema Drift Analyses": [
        "compile",
        "--select",
        "path:analyses/SFDC_schema_drift",
    ],
    "SFDC Current Profiles": [
        "run",
        "--select",
        "tag:sfdc_profile",
        "--vars",
        '{"sfdc_profile_name": "current"}',
    ],
    "SFDC BASE Profiles": [
        "run",
        "--select",
        "tag:sfdc_profile",
        "--vars",
        '{"sfdc_profile_name": "base"}',
    ],
}
