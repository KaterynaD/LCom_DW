-- depends_on: {{ source("fivetran_salesforce_quickstart","user") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","user"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["x_2020_closed_won_c", "quota_c", "longitude", "x_2020_open_pipline_c", "latitude"] ) }}

{% endif %}
