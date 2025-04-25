-- depends_on: {{ source("fivetran_salesforce_quickstart","rcsfl_admin_setting_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","rcsfl_admin_setting_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["setup_owner_id", "name", "id", "rcsfl_hvs_disposition_field_c", "last_modified_by_id", "created_by_id"] ) }}

{% endif %}
