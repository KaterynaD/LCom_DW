-- depends_on: {{ source("fivetran_salesforce_quickstart","order") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","order"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["minutes_last_modified_c", "sbqq_tax_amount_c", "sbqq_total_amount_c", "total_amount"] ) }}

{% endif %}
