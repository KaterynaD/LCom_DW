-- depends_on: {{ source("fivetran_salesforce_quickstart","codesters_codesters_organization_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","codesters_codesters_organization_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_last_license_end_date_c", "codesters_first_license_start_date_c", "last_activity_date"] ) }}

{% endif %}
