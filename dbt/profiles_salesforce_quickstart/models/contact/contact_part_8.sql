-- depends_on: {{ source("fivetran_salesforce_quickstart","contact") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","contact"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_created_date_no_time_c", "gong_current_flow_task_due_date_c", "customer_date_c", "rejected_date_c", "last_platform_login_date_c", "returned_date_hubspot_c", "eval_registration_date_c", "eval_last_activity_date_c", "sql_date_c", "sql_date_hubspot_c", "qualifying_date_c", "returned_date_c", "agileed_agile_ed_latest_update_date_c", "mql_date_del_c", "dsp_registration_date_c", "rejected_date_hubspot_c", "training_date_c", "cm_codesters_account_creation_date_c", "renewal_date_c", "eval_expiration_date_c", "target_start_date_c", "last_activity_date", "dsp_last_activity_date_c", "birthdate", "qualifying_date_hubspot_c", "first_platform_login_date_c"] ) }}

{% endif %}
