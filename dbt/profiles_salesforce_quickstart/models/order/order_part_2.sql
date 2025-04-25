-- depends_on: {{ source("fivetran_salesforce_quickstart","order") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","order"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["net_suite_link_c", "order_final_status_c", "integration_status_c", "primary_sales_rep_c"] ) }}

{% endif %}
