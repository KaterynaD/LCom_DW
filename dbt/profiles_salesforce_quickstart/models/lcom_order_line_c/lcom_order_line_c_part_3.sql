-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_order_line_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_order_line_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["lcom_order_line_start_date_c", "last_activity_date", "lcom_order_line_end_date_c"] ) }}

{% endif %}
