-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_order_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_order_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["lcom_license_count_c", "lcom_licenses_ready_to_sync_count_c", "lcom_order_line_count_c"] ) }}

{% endif %}
