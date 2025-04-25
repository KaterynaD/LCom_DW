-- depends_on: {{ source("fivetran_salesforce_quickstart","case") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","case"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_last_login_c", "survey_send_date_time_c", "_fivetran_synced", "closed_date", "sla_start_date", "last_modified_date", "jira_ticket_last_update_date_c", "last_viewed_date", "created_date", "date_and_time_it_was_c", "last_referenced_date", "system_modstamp", "stop_start_date", "jira_ticket_opened_date_c", "sla_exit_date", "first_reply_to_customer_completed_c"] ) }}

{% endif %}
