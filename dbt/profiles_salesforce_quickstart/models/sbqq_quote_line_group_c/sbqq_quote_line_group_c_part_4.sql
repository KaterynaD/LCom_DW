-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_line_group_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_line_group_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["sbqq_target_customer_amount_c", "sbqq_net_total_c", "sbqq_list_total_c", "sbqq_customer_total_c"] ) }}

{% endif %}
