-- depends_on: {{ source("fivetran_salesforce_quickstart","contact") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","contact"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["days_since_registration_c", "hours_since_mql_c", "days_out_c"] ) }}

{% endif %}
