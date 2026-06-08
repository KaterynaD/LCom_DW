{% macro set_QA_environment() %}
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

  {# Schemas #}
  {{ create_schemas() }}

{% endmacro %}
