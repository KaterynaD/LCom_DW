-- depends_on: {{ source("fivetran_salesforce_quickstart","state_profile_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","state_profile_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["nexus_transaction_threshold_c", "annual_transactions_c"] ) }}

{% endif %}
