-- depends_on: {{ source("fivetran_salesforce_quickstart","switches_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","switches_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_deleted", "automation_off_c", "is_deleted", "automation_off_code_c"] ) }}

{% endif %}
