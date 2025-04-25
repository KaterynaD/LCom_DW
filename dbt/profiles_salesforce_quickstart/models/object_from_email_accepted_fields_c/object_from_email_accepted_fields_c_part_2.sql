-- depends_on: {{ source("fivetran_salesforce_quickstart","object_from_email_accepted_fields_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","object_from_email_accepted_fields_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["object_name_c", "field_name_c", "setup_owner_id", "created_by_id", "name", "id", "last_modified_by_id"] ) }}

{% endif %}
