-- depends_on: {{ source("fivetran_salesforce_quickstart","switches_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","switches_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["setup_owner_id", "created_by_id", "name", "id", "last_modified_by_id"] ) }}

{% endif %}
