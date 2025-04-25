-- depends_on: {{ source("fivetran_salesforce_quickstart","case") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","case"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["quick_note_c", "service_contract_id", "supplied_email", "milestone_status", "jira_link_c", "id", "netsuite_case_number_c", "master_record_id", "contact_fax", "migration_tool_c", "jira_status_c", "codesters_id_c", "business_hours_id", "product_id", "solution_c"] ) }}

{% endif %}
