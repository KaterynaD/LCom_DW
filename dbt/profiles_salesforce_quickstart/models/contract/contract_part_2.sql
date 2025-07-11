-- depends_on: {{ source("fivetran_salesforce_quickstart","contract") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","contract"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["data_quality_score_c", "sbqq_active_contract_c"] ) }}

{% endif %}
