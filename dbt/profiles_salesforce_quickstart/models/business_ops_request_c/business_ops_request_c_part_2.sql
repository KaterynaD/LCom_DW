-- depends_on: {{ source("fivetran_salesforce_quickstart","business_ops_request_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","business_ops_request_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["resolution_c", "request_type_c", "jira_ticket_c", "status_c", "opportunity_c", "last_modified_by_id", "account_c", "description_c", "impact_on_customers_c", "if_other_please_specify_c", "owner_id", "impacted_flow_c", "description_text_c", "assigned_to_email_c", "impact_on_team_c", "created_by_id", "priority_c", "impact_on_job_function_c", "primary_object_c", "requestor_c", "subject_c", "project_sub_type_c", "impact_on_revenue_c", "name", "quote_c", "id", "deal_document_stage_c", "assigned_to_c", "impact_on_learning_com_c", "system_c", "severity_c"] ) }}

{% endif %}
