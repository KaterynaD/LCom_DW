-- depends_on: {{ source("fivetran_salesforce_quickstart","campaign") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","campaign"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_license_days_c", "expected_response", "codesters_license_seats_c", "hierarchy_number_sent", "number_sent"] ) }}

{% endif %}
