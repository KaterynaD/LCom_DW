-- depends_on: {{ source("fivetran_salesforce_quickstart","case") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","case"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["case_ready_to_survey_c", "out_of_office_c", "_fivetran_deleted", "is_escalated", "bad_c", "already_closed_c", "case_solved_in_chat_c", "case_auto_closed_c", "good_c", "confirmed_resolution_c", "csat_survey_sent_c", "codesters_case_c", "is_closed", "suppress_system_emails_c", "is_closed_on_create", "initial_response_captured_c", "product_feedback_submitted_c", "is_deleted", "sales_escalation_c", "jira_ticket_submitted_c", "fix_c", "case_auto_close_warning_sent_c", "is_stopped"] ) }}

{% endif %}
