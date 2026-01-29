#!/usr/bin/env python3
"""
Script to set default Airflow variables if they do not exist.
This script is intended to be run in CI/CD to ensure required variables are initialized.
"""

from airflow.models import Variable


def set_default_if_not_exists(var_name, default_value):
    """
    Set a variable to its default value if it does not already exist.

    Args:
        var_name (str): The name of the Airflow variable
        default_value (str): The default value to set if the variable doesn't exist
    """
    try:
        # Try to get the variable without default to check if it exists
        Value = Variable.get(var_name)
        print(f"Variable '{var_name}' already exists: '{Value}'")
    except KeyError:
        # Variable doesn't exist, set it to the default
        Variable.set(var_name, default_value)
        print(f"Variable '{var_name}' set to default value: '{default_value}'")


if __name__ == "__main__":
    # ------------------------------------------------------------------
    # Define the variables and their defaults
    # ------------------------------------------------------------------
    variables_to_set = {
        # Existing variables
        "SCHEDULE_SFDC_SCHEMA_DRIFT_AUDIT": "0 20 * * *",
        "RUN_COLUMN_LINEAGE_FLAG": "YES",
        "USE_EXISTING_BASE_PROFILE": "NO",
        "ALERT_EMAIL": "reportinganalytics@learning.com",
        "INIT_DBT_PROJECT": "NO",

        # ------------------------------------------------------------------
        # LCom DW full scheduled run toggles (default = Yes)
        # ------------------------------------------------------------------
        "RUN__DROP_ALL_FK": "YES",
        "RUN__COMMON": "YES",
        "RUN__LICENSING": "YES",
        "RUN__TRAINING_SESSIONS": "YES",
        "RUN__SUPPORT": "YES",
        "RUN__REVENUE": "YES",
        "RUN__MARKETING": "YES",        
        "RUN__CDU": "YES",
        "RUN__SNAPSHOTS": "YES",
        "RUN__RECREATE_ALL_FK": "YES",
        "RUN__TESTS": "YES",
    }

    # Set each variable if it doesn't exist
    for var_name, default_value in variables_to_set.items():
        set_default_if_not_exists(var_name, default_value)

    print("Airflow variables initialization complete.")