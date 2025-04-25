-- depends_on: {{ source("fivetran_salesforce_quickstart","contract") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","contract"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["sbqq_amendment_renewal_behavior_c", "billing_street", "sbqq_amendment_opportunity_stage_c", "shipping_state_code", "billing_geocode_accuracy", "billing_state"] ) }}

{% endif %}
