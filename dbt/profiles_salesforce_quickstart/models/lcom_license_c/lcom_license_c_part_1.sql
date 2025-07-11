-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_license_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_license_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_deleted", "ready_to_sync_c", "is_active_c", "is_linked_c", "is_disabled_c", "is_synced_c", "is_deleted", "is_valid_c", "enforce_date_restrictions_c"] ) }}

{% endif %}
