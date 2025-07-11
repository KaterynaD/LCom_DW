-- depends_on: {{ source("fivetran_salesforce_quickstart","opportunity") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","opportunity"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["trigger_time_05_c", "trigger_time_06_c", "last_activity_changed_date_plus_30_c", "_fivetran_synced", "closed_won_date_time_c", "last_modified_date", "time_moved_to_ready_for_sales_support_c", "last_viewed_date", "last_stage_change_date", "po_received_date_time_c", "created_date", "license_provisioned_date_c", "last_referenced_date", "system_modstamp", "validation_bypass_date_time_c"] ) }}

{% endif %}
