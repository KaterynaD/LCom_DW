-- depends_on: {{ source("fivetran_salesforce_quickstart","contact") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","contact"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["number_of_opps_at_50_c"] ) }}

{% endif %}
