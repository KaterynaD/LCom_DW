-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_suite_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_suite_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_deleted", "is_synced_c", "is_deleted", "is_active_c", "is_linked_c"] ) }}

{% endif %}
