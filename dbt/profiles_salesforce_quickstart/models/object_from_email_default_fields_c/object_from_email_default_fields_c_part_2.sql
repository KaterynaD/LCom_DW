-- depends_on: {{ source("fivetran_salesforce_quickstart","object_from_email_default_fields_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","object_from_email_default_fields_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["default_value_text_c", "setup_owner_id", "name", "id", "last_modified_by_id", "object_name_c", "field_name_c", "created_by_id"] ) }}

{% endif %}
