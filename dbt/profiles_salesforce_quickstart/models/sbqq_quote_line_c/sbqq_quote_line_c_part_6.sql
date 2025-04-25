-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_line_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_line_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["jitterbit_start_date_c", "quoteend_date_c", "sbqq_effective_start_date_c", "close_date_c", "sbqq_effective_end_date_c", "prorated_start_date_c", "sbqq_end_date_c", "sbqq_start_date_c", "actual_start_date_c", "actual_end_date_c", "sbqq_earliest_valid_amendment_start_date_c"] ) }}

{% endif %}
