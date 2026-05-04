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

  {# 1) Schemas #}
  {{ create_schemas() }}

  {# 1) Tables #}

  {{ log('create_common_dim_calendar_table', info=True) }}
  {{ create_common_dim_calendar_table() }}

  {{ log('create_fact_launches_weekly_snapshots_table', info=True) }}
  {{ create_fact_launches_weekly_snapshots_table() }}
  {{ log('create_fact_launches_monthly_snapshots_table', info=True) }}
  {{ create_fact_launches_monthly_snapshots_table() }}
  {{ log('create_fact_students_completions_monthly_snapshots', info=True) }}
  {{ create_fact_students_completions_monthly_snapshots() }}
  {{ log('create_fact_usage_monthly_snapshots_table', info=True) }}
  {{ create_fact_usage_monthly_snapshots_table() }}

  {{ log('create_stg_opportunities_chain_of_renewals', info=True) }}
  {{ create_stg_opportunities_chain_of_renewals() }}
  {{ log('create_stg_opportunities_chain_of_renewals_v2', info=True) }}
  {{ create_stg_opportunities_chain_of_renewals_v2() }}
  {{ log('create_sfdc_ultimate_parent_accounts_data', info=True) }}
  {{ create_sfdc_ultimate_parent_accounts_data() }}

  {# 1) Stored Procedures #}
  {{ log('create_lc_load_students_usage_monthly_snapshots', info=True) }}
  {{ create_lc_load_students_usage_monthly_snapshots() }}
  {{ log('create_lc_load_students_completions_monthly_snapshots', info=True) }}
  {{ create_lc_load_students_completions_monthly_snapshots() }}
  {{ log('create_processing_opportunities_chain_of_renewals', info=True) }}
  {{ create_processing_opportunities_chain_of_renewals() }}
  {{ log('create_processing_opportunities_chain_of_renewals_v2', info=True) }}
  {{ create_processing_opportunities_chain_of_renewals_v2() }}
  {{ log('create_processing_ultimate_parent_accounts', info=True) }}
  {{ create_processing_ultimate_parent_accounts() }}

  {{ log('create_lc_load_launches_weekly_snapshots', info=True) }}
  {{ create_lc_load_launches_weekly_snapshots() }}
  {{ log('create_lc_load_launches_monthly_snapshots', info=True) }}
  {{ create_lc_load_launches_monthly_snapshots() }}
  
{% endmacro %}
