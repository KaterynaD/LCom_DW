-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_order_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_order_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["maximum_end_date_c", "minimum_order_start_date_c", "order_start_date_c", "order_end_date_c", "last_activity_date"] ) }}

{% endif %}
