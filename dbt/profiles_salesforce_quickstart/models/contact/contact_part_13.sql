-- depends_on: {{ source("fivetran_salesforce_quickstart","contact") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","contact"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["created_date_formula_c", "codesters_last_login_c", "codesters_created_date_c", "_fivetran_synced", "last_curequest_date", "time_first_seen_c", "last_cuupdate_date", "last_activity_time_and_date_c", "last_modified_date", "last_viewed_date", "email_bounced_date", "time_of_last_session_c", "first_email_date_time", "created_date", "mql_date_and_time_stamp_c", "first_call_date_time", "agileed_last_sync_c", "time_last_seen_c", "last_referenced_date", "system_modstamp", "last_support_interaction_c"] ) }}

{% endif %}
