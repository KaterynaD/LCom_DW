-- depends_on: {{ source("fivetran_salesforce_quickstart","account") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","account"), where_clause="org_type_c='District'" , exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_synced", "last_modified_date", "last_viewed_date", "created_date", "agileed_personnel_last_sync_c", "agileed_connect_link_metrics_run_start_c", "agileed_last_sync_c", "last_referenced_date", "system_modstamp"] ) }}

{% endif %}
