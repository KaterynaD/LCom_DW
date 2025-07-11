-- depends_on: {{ source("fivetran_salesforce_quickstart","record_type") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","record_type"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["name", "id", "sobject_type", "last_modified_by_id", "business_process_id", "developer_name", "description", "namespace_prefix", "created_by_id"] ) }}

{% endif %}
