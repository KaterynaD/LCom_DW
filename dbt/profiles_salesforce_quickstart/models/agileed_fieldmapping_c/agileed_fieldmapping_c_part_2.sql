-- depends_on: {{ source("fivetran_salesforce_quickstart","agileed_fieldmapping_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","agileed_fieldmapping_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["agileed_field_api_name_c", "agileed_s_object_field_name_c", "agileed_s_object_c", "setup_owner_id", "name", "id", "agileed_prefer_c", "agileed_data_type_c", "last_modified_by_id", "created_by_id"] ) }}

{% endif %}
