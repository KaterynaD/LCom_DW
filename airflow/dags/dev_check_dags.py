
from airflow.models.dagbag import DagBag
from airflow.configuration import conf

def main() -> None:
    # Airflow will automatically read DAGs folder from env variable:
    # AIRFLOW__CORE__DAGS_FOLDER
    dags_folder = conf.get("core", "dags_folder")

    print(f"\n>>> Airflow DAGs folder: {dags_folder}\n")


    print(f"Loading DAGs from: {dags_folder}")

    dag_bag = DagBag(dag_folder=str(dags_folder), include_examples=False)

    if dag_bag.import_errors:
        print("\n❌ Import errors detected:")
        for file, err in dag_bag.import_errors.items():
            print(f" - {file}: {err}")
    else:
        print("\n✅ No import errors 🎉")

    print(f"\nDAGs loaded: {len(dag_bag.dags)}")
    for dag_id in sorted(dag_bag.dags.keys()):
        print(f" - {dag_id}")


if __name__ == "__main__":
    print(">>> dev_check_dags.py starting...")  # debug print
    main()



