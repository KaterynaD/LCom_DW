-- depends_on: {{ source("fivetran_salesforce_quickstart","contact") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","contact"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["last_modified_by_id", "owner_id", "description", "mailing_postal_code", "power_teacher_c", "planned_usage_c", "vidcode_org_id_c", "mql_type_c", "activity_metric_id", "master_record_id", "age_group_c"] ) }}

{% endif %}
