-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_line_group_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_line_group_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_deleted", "sbqq_separate_contract_c", "is_deleted", "sbqq_optional_c"] ) }}

{% endif %}
