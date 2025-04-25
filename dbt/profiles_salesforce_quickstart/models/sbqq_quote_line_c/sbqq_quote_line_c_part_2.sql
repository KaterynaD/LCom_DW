-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_line_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_line_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["whole_years_c", "pyterm_c", "template_sorting_order_c"] ) }}

{% endif %}
