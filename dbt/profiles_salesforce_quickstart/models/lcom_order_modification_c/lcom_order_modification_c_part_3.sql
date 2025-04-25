-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_order_modification_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_order_modification_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["modified_date_c", "last_activity_date"] ) }}

{% endif %}
