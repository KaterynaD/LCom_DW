-- depends_on: {{ source("fivetran_salesforce_quickstart","codesters_codesters_organization_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","codesters_codesters_organization_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_over_capacity_used_seats_c", "codesters_over_capacity_seats_c", "codesters_is_over_by_c"] ) }}

{% endif %}
