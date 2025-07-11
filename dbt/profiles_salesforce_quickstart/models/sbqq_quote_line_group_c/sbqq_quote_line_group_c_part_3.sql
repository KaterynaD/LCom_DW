-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_line_group_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_line_group_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["sbqq_end_date_c", "sbqq_start_date_c"] ) }}

{% endif %}
