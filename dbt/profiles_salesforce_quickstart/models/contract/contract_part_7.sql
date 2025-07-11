-- depends_on: {{ source("fivetran_salesforce_quickstart","contract") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","contract"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["contract_arr_c", "opp_delta_c", "renewal_opp_amount_c", "source_opp_amount_c", "subscription_roll_up_c", "contracted_arr_c"] ) }}

{% endif %}
