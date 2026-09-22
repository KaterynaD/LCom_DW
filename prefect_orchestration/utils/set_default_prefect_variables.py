"""Bootstrap default Prefect variables for the orchestration project.

Purpose:
    Create a predictable baseline set of Prefect variables so flows can be
    enabled, disabled, and notified consistently across environments.

Production notes:
    Review the defaults before running in a shared or production workspace to
    ensure toggle values match the intended deployment behavior.
"""

from __future__ import annotations





from prefect import get_run_logger
from prefect.variables import Variable



VARIABLES_TO_SET = {
    "use_existing_base_profile": "NO",
    "alert_email": "kdrogaieva@learning.com",
    "target": "dev",
    "run__drop_all_fk": "YES",
    "run__common": "YES",
    "run__licensing": "YES",
    "run__training_sessions": "YES",
    "run__support": "YES",
    "run__revenue": "YES",
    "run__marketing": "YES",
    "run__cdu": "YES",
    "run__snapshots": "YES",
    "run__recreate_all_fk": "YES",
    "run__tests": "YES",
    "run__qa_tests": "YES",
    "run__prod_deployment": "YES",
    "target_qa": "QA",
    "run__generate_dbt_docs": "YES",
    "run__colibri_lineage": "YES",
}


def set_default_prefect_variables() -> None:
    """Create missing Prefect variables using the project's default values."""
    def log_message(message: str) -> None:
        try:
            logger = get_run_logger()
            logger.info(message)
        except Exception:
            # Fallback for standalone script execution without an active
            # Prefect flow/task run context.
            print(message)

    for variable_name, default_value in VARIABLES_TO_SET.items():
        existing_value = Variable.get(
            variable_name,
            default=None,
        )

        if existing_value is None:
            Variable.set(
                variable_name,
                default_value,
            )

            log_message(
                f"Created Prefect variable: "
                f"{variable_name} = {default_value}"
            )
        else:
            log_message(
                f"Prefect variable already exists: "
                f"{variable_name} = {existing_value}. "
                f"No change made."
            )




if __name__ == "__main__":
    set_default_prefect_variables()

