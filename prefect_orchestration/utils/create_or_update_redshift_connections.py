"""Create or update Prefect Redshift connections from the dbt profile."""

from __future__ import annotations

import os
import yaml

from prefect import get_run_logger
from prefect_sqlalchemy import SqlAlchemyConnector, ConnectionComponents

from environment_utils import get_env_path


def create_or_update_redshift_connections() -> None:
    """Create or update Prefect Redshift connections from dbt profiles.yml."""

    def log_message(message: str) -> None:
        try:
            logger = get_run_logger()
            logger.info(message)
        except Exception:
            # Fallback for standalone script execution without an active
            # Prefect flow/task run context.
            print(message)

    dbt_profiles_dir = get_env_path("DBT_PROFILES_DIR")
    profiles_path = os.path.join(dbt_profiles_dir, "profiles.yml")

    with open(profiles_path, "r") as f:
        profiles = yaml.safe_load(f)

    profile = profiles["LCom_DW"]
    default_target = profile["target"]

    for output_name, target_config in profile["outputs"].items():
        block_name = f"redshift-{output_name.lower()}"

        connection = SqlAlchemyConnector(
            connection_info=ConnectionComponents(
                driver="redshift+psycopg2",
                host=target_config["host"],
                port=target_config.get("port", 5439),
                username=target_config["user"],
                password=target_config["password"],
                database=target_config["dbname"],
            )
        )

        connection.save(
            block_name,
            overwrite=True,
        )

        log_message(
            f"Created or updated Prefect Redshift connection: {block_name}"
        )

        if output_name == default_target:
            connection.save(
                "redshift-default",
                overwrite=True,
            )

            log_message(
                f"Created or updated Prefect Redshift connection: "
                f"redshift-default"
            )


if __name__ == "__main__":
    create_or_update_redshift_connections()