# EC2 Airflow + dbt in Docker

This folder contains everything needed to run **Airflow + dbt (Redshift)** in Docker on an **EC2 Amazon Linux 2023** instance.

Repo layout (relevant parts):

```
transformations/
├── airflow/
│   └── dags/
├── dbt/
│   └── LCom_DW/
└── infra/
    └── ec2-airflow-docker/
        ├── Dockerfile
        ├── docker-compose.yml
        ├── init_airflow.sh
        ├── update_dbt_and_start_airflow.sh
        ├── stop_airflow.sh
        ├── .env.example
        ├── logs/
        ├── plugins/
        └── pgdata/
```

dbt profiles live outside the repo:

```
/home/kdrogaieva/dbt_profile/profiles.yml
```

## 1. Prerequisites on EC2

Install Docker, Compose, Git, and clone the repository.

## 2. One-time setup

Create dbt_profile, copy profiles.yml, prepare infra folder, create logs/plugins/pgdata, create .env from .env.example, build Docker image, run init_airflow.sh.

## 3. Daily workflow

Use update_dbt_and_start_airflow.sh to pull repo, start Airflow services, and run dbt deps.

Use stop_airflow.sh to stop services.

## 4. Running dbt manually

Use docker compose exec airflow-webserver bash then navigate to /opt/airflow/transformations/dbt/LCom_DW.

## 5. Persisted folders

logs/ and pgdata/ are bind mounted and should be ignored by Git.


