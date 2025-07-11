-- depends_on: {{ source("fivetran_salesforce_quickstart","state_profile_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","state_profile_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["nexus_threshold_c", "current_arr_c", "state_cs_funding_amount_c", "digital_equity_funding_c", "computer_science_funding_c"] ) }}

{% endif %}
