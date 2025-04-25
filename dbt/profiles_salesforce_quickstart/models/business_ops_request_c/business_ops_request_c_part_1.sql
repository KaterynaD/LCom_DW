-- depends_on: {{ source("fivetran_salesforce_quickstart","business_ops_request_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","business_ops_request_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["is_current_c", "_fivetran_deleted", "uploaded_to_sfdc_and_sharepoint_c", "change_performed_c", "is_deleted", "project_c"] ) }}

{% endif %}
