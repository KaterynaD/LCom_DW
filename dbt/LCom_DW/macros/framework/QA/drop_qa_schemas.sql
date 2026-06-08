{% macro drop_qa_schemas() %}
  {# 1) Must be explicitly invoked in QA target #}
  {% if target.name | lower != 'qa' %}
    {% do exceptions.raise_compiler_error(
      "Refusing to run: target.name is '" ~ target.name ~ "'. This macro only runs on target QA."
    ) %}
  {% endif %}


  {# 2) Must match the expected QA database name (hard block) #}
  {% set expected_db = (var('qa_database_name', 'QA') | string) %}
  {% set target_db = (target.database | string) %}

  {% if target_db | lower != expected_db | lower %}
    {% do exceptions.raise_compiler_error(
      "Refusing to run: connected database '" ~ target_db ~
      "' does not match expected QA database '" ~ expected_db ~ "'."
    ) %}
  {% endif %}

  {# 3) Double-check at runtime too #}
  {% if execute %}
    {% set db_check = run_query("select current_database() as db") %}
    {% set actual_db = (db_check.columns[0].values()[0] | string) %}
    {% if actual_db | lower != expected_db | lower %}
      {% do exceptions.raise_compiler_error(
        "Refusing to run: current_database()='" ~ actual_db ~
        "' does not match expected QA database '" ~ expected_db ~ "'."
      ) %}
    {% endif %}
  {% endif %}

  {# dry_run defaults to true #}
  {% set dry_run = var('dry_run', true) %}

  {# 4) List ONLY schemas owned by current_user (and skip system schemas) #}
  {% set list_sql %}
    select n.nspname as schema_name
    from pg_namespace n
    join pg_user u on u.usesysid = n.nspowner
    where u.usename = current_user
      and n.nspname not in ('pg_catalog', 'information_schema', 'public')
      and n.nspname not like 'pg\_%' escape '\\'
    order by 1
  {% endset %}

  {% if not execute %}
    {{ return("") }}
  {% endif %}

  {% set res = run_query(list_sql) %}

  {% if res is none or (res.rows | length) == 0 %}
    {% do log("No schemas owned by current_user found to drop. Nothing to do.", info=true) %}
    {{ return("") }}
  {% endif %}

  {% do log("Matched schemas owned by current_user to drop (" ~ (res.rows | length) ~ "):", info=true) %}
  {% for r in res.rows %}
    {% do log("  - " ~ (r[0] | string), info=true) %}
  {% endfor %}

  {% for r in res.rows %}
    {% set s = (r[0] | string) %}
    {% set drop_sql = "drop schema if exists " ~ expected_db ~"."~ s ~ " cascade" %}

    {% if dry_run %}
      {% do log("[DRY RUN] " ~ drop_sql ~ ";", info=true) %}
    {% else %}
      {% do log("Executing: " ~ drop_sql ~ ";", info=true) %}
      {% do run_query(drop_sql) %}
    {% endif %}
  {% endfor %}

  {% if dry_run %}
    {% do log("Dry run complete. Re-run with --vars '{dry_run: false,  ...}' to execute.", info=true) %}
  {% else %}
    {% do log("Schema cleanup complete.", info=true) %}
  {% endif %}

  {{ return("") }}
{% endmacro %}