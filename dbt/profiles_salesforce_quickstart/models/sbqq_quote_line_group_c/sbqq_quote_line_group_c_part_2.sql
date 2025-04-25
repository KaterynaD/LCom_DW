-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_line_group_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_line_group_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["sbqq_solution_group_c", "last_modified_by_id", "sbqq_description_c", "created_by_id", "sbqq_quote_process_c", "sbqq_quote_c", "sbqq_favorite_c", "name", "id", "sbqq_billing_frequency_c", "sbqq_account_c", "sbqq_source_c"] ) }}

{% endif %}
