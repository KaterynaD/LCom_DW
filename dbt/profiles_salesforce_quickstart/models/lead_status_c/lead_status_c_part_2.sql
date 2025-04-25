-- depends_on: {{ source("fivetran_salesforce_quickstart","lead_status_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lead_status_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["contact_c", "name", "id", "last_modified_by_id", "owner_id", "created_by_id"] ) }}

{% endif %}
