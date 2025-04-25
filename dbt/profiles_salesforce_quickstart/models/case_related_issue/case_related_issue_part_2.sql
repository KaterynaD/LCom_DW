-- depends_on: {{ source("fivetran_salesforce_quickstart","case_related_issue") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","case_related_issue"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["relationship_type", "case_id", "related_entity_type", "created_by_id", "name", "related_issue_id", "id", "last_modified_by_id"] ) }}

{% endif %}
