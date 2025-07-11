-- depends_on: {{ source("fivetran_salesforce_quickstart","codesters_codesters_license_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","codesters_codesters_license_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_end_date_c", "codesters_start_date_c", "codesters_codesters_end_date_c", "last_activity_date", "codesters_codesters_start_date_c"] ) }}

{% endif %}
