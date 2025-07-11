-- depends_on: {{ source("fivetran_salesforce_quickstart","lead") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lead"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_last_login_c", "db_created_date_without_time_c", "codesters_created_date_c", "_fivetran_synced", "first_email_date_time", "created_date", "first_call_date_time", "agileed_last_sync_c", "last_modified_date", "last_viewed_date", "email_bounced_date", "last_referenced_date", "system_modstamp", "sql_date_c", "mql_date_c", "agileed_agile_ed_latest_update_date_c"] ) }}

{% endif %}
