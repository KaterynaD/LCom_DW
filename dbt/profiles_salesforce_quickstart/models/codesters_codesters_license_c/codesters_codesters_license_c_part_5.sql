-- depends_on: {{ source("fivetran_salesforce_quickstart","codesters_codesters_license_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","codesters_codesters_license_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_seats_used_c", "codesters_seats_c", "codesters_codesters_seats_c", "codesters_codesters_seats_used_c"] ) }}

{% endif %}
