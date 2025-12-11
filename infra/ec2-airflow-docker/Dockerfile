FROM apache/airflow:2.10.2-python3.12

# Install git inside the container (needed for dbt git-based packages)
USER root
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Tell git to trust the mounted repo path
RUN git config --global --add safe.directory /opt/airflow/transformations

# Install dbt as airflow user (Airflow image best practice)
USER airflow
RUN pip install \
      "dbt-core==1.10.3" \
      "dbt-redshift==1.9.5"

# Return to root (default for this image)
USER root
