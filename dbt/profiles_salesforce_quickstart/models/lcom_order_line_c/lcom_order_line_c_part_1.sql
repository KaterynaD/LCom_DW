-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_order_line_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_order_line_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_deleted", "is_deleted", "license_set_up_c"] ) }}

{% endif %}
