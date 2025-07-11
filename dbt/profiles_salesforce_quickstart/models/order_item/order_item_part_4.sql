-- depends_on: {{ source("fivetran_salesforce_quickstart","order_item") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","order_item"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["unit_price", "sbqq_total_amount_c", "sbqq_list_price_c", "total_price", "sbqq_quoted_list_price_c", "sbqq_unprorated_net_price_c", "list_price", "sbqq_tax_amount_c"] ) }}

{% endif %}
