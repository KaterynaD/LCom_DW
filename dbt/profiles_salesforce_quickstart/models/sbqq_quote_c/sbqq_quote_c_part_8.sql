-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["total_quote_lines_c", "count_of_gs_c", "lcom_order_lines_count_c", "sbqq_line_item_count_c", "provisioned_lines_c"] ) }}

{% endif %}
