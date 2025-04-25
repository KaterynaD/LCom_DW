-- depends_on: {{ source("fivetran_salesforce_quickstart","campaign") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","campaign"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_opportunity_close_date_c", "last_activity_date", "start_date", "end_date", "codesters_license_start_date_c", "codesters_license_end_date_c"] ) }}

{% endif %}
