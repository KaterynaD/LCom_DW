-- depends_on: {{ source("fivetran_salesforce_quickstart","lead") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lead"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_url_c", "data_quality_description_c"] ) }}

{% endif %}
