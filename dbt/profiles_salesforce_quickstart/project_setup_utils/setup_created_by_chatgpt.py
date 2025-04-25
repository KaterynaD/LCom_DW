import os
import yaml
import psycopg2
from collections import defaultdict

# === CONFIGURATION ===
BASE_FOLDER = r"models"
SCHEMA_NAME = 'fivetran_salesforce_quickstart'
EXCLUDED_VIEWS = {
    'data_lineage_node_sync_status', 'data_lineage_node_sync_status_feed',
    'data_lineage_node_sync_status_history', 'incp_incident_lv_fields_c',
    'incp_time_zone_selection_c'
}
PROFILE_NAME = 'profiles_salesforce_quickstart'
TARGET = 'default'
RAW_DATABASE = 'rawdata'
MAX_COLUMNS = 50


def load_dbt_profile():
    profile_path = os.path.expanduser("C:\\Users\\KDrogaieva\\.dbt\\profiles.yml")
    with open(profile_path, 'r') as f:
        profiles = yaml.safe_load(f)

    profile = profiles[PROFILE_NAME]
    target = profile['target']
    credentials = profile['outputs'][target]

    return {
        'host': credentials['host'],
        'dbname': credentials['dbname'],
        'user': credentials['user'],
        'password': credentials['password'],
        'port': credentials.get('port', 5439)
    }


def get_dbt_connection():
    creds = load_dbt_profile()
    conn = psycopg2.connect(
        host=creds['host'],
        dbname=creds['dbname'],
        user=creds['user'],
        password=creds['password'],
        port=creds['port']
    )
    return conn


def get_non_empty_views(conn):
    with conn.cursor() as cur:
        cur.execute(f"""
            SELECT table_name 
            FROM information_schema.views 
            WHERE table_schema = %s
        """, (SCHEMA_NAME,))
        all_views = [row[0] for row in cur.fetchall()]
        valid_views = []

        for view in all_views:
            if view in EXCLUDED_VIEWS:
                continue
            try:
                cur.execute(f'SELECT 1 FROM "{RAW_DATABASE}"."{SCHEMA_NAME}"."{view}" LIMIT 1')
                if cur.fetchone():
                    valid_views.append(view)
            except Exception as e:
                print(f"Skipping view {view} due to error: {e}")
        return valid_views


def get_columns_by_type(conn, view):
    with conn.cursor() as cur:
        cur.execute(f"""
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = %s AND table_name = %s
        """, (SCHEMA_NAME, view))
        type_groups = defaultdict(list)
        for col, dtype in cur.fetchall():
            type_groups[dtype].append(col)
        return type_groups


def write_sources_yml(views):
    yml_path = os.path.join(BASE_FOLDER, 'sources.yml')
    source_dict = {
        'sources': [{
            'name': SCHEMA_NAME,
            'quoting': {
                'database': False,
                'schema': False,
                'identifier': False
            },
            'tables': [{'name': v} for v in views]
        }]
    }
    with open(yml_path, 'w') as f:
        yaml.dump(source_dict, f, sort_keys=False)


def generate_sql_files(view, grouped_columns):
    view_folder = os.path.join(BASE_FOLDER, view)
    os.makedirs(view_folder, exist_ok=True)
    part_num = 1
    sql_files = []

    for dtype, columns in grouped_columns.items():
        for i in range(0, len(columns), MAX_COLUMNS):
            part_columns = columns[i:i + MAX_COLUMNS]
            part_filename = f"{view}_part_{part_num}.sql"
            filepath = os.path.join(view_folder, part_filename)
            content = f"""-- depends_on: {{{{ source("{SCHEMA_NAME}","{view}") }}}}
{{% if execute %}}

  {{{{ dbt_profiler.get_profile(relation=source("{SCHEMA_NAME}","{view}"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=[{", ".join([f'"{col}"' for col in part_columns])}] ) }}}}

{{% endif %}}
"""
            with open(filepath, 'w') as f:
                f.write(content)
            sql_files.append(part_filename)
            part_num += 1

    # Create union all file
    final_sql_path = os.path.join(BASE_FOLDER, f"{view}.sql")
    with open(final_sql_path, 'w') as f:
        unions = "\nunion all\n".join([f'select * from {{{{  ref("{os.path.splitext(f)[0]}") }}}}' for f in sql_files])
        f.write(unions)


def main():
    conn = get_dbt_connection()
    views = get_non_empty_views(conn)
    write_sources_yml(views)

    for view in views:
        grouped_columns = get_columns_by_type(conn, view)
        generate_sql_files(view, grouped_columns)

    print("✅ All files generated successfully.")


if __name__ == "__main__":
    main()
