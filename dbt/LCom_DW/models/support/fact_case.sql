{{
  config(

    materialized='table',    
    sort='created_date', 
    dist='account_id'  ,
    post_hook=[        
        '{{ create_FK(target.database,model.schema,model.name, "account_id","common","dim_account","account_id") }}',
        '{{ create_FK(target.database,model.schema,model.name, "owner_id","common","dim_employee","employee_id") }}',
        '{{ create_FK(target.database,"support","fact_case_history","case_id",model.schema,model.name, "case_id") }}',
        '{{ update_FACT_CASE_HISTORY_changed_UK() }}'
    
    ]
    )
}}

with data as (
select
stg.id 	 as case_id	,
isnull(a.account_id, '{{ var("default_ID") }}') as account_id	,
isnull(stg.account_id, '{{ var("default_ID") }}') as sfdc_account_id	,
isnull(stg.account_owner_c , '{{ var("default_varchar") }}') as account_owner	,
isnull(stg.account_owner_email_c, '{{ var("default_varchar") }}') as account_owner_email	,
isnull(stg.already_closed_c, {{ var("default_boolean") }}) as already_closed	,
isnull(stg.case_auto_close_warning_sent_c , {{ var("default_boolean") }}) as case_auto_close_warning_sent	,
isnull(stg.case_number , '{{ var("default_varchar") }}') as case_number	,
isnull(stg.case_owner_email_c , '{{ var("default_varchar") }}') as case_owner_email	,
isnull(stg.case_ready_to_survey_c , {{ var("default_boolean") }}) as case_ready_to_survey	,
isnull(stg.closed_date ,'{{ var("default_date") }}') as closed_date	,
isnull(stg.codesters_case_c, {{ var("default_boolean") }}) as codesters_case	,
isnull(stg.codesters_classes_c , {{ var("default_numeric") }}) as codesters_classes	,
isnull(stg.codesters_i_2_c_student_avg_c, {{ var("default_numeric") }}) as codesters_i_2_c_student_avg	,
isnull(stg.codesters_i_2_c_student_completion_c, {{ var("default_numeric") }}) as codesters_i_2_c_student_completion	,
isnull(stg.codesters_students_c, {{ var("default_numeric") }}) as codesters_students	,
isnull(stg.confirmed_resolution_c , {{ var("default_boolean") }}) as confirmed_resolution	,
isnull(stg.contact_email, '{{ var("default_varchar") }}') as contact_email	,
isnull(stg.contact_id , '{{ var("default_varchar") }}') as contact_id	,
isnull(stg.contact_phone, '{{ var("default_varchar") }}') as contact_phone	,
isnull(stg.created_date	 AT TIME ZONE 'PST','{{ var("default_date") }}') as created_date	,
isnull(stg.csat_response_c , '{{ var("default_varchar") }}') as csat_response	,
isnull(stg.data_quality_description_c , '{{ var("default_varchar") }}') as data_quality_description	,
isnull(stg.data_quality_score_c, {{ var("default_numeric") }}) as data_quality_score	,
isnull(stg.description , '{{ var("default_varchar") }}') as description	,
isnull(stg.initial_response_captured_c , {{ var("default_boolean") }}) as initial_response_captured	,
isnull(stg.is_closed, {{ var("default_boolean") }}) as is_closed	,
isnull(stg.is_escalated, {{ var("default_boolean") }}) as is_escalated	,
isnull(stg.issues_c, '{{ var("default_varchar") }}') as issues	,
isnull(stg.jira_ticket_submitted_c , {{ var("default_boolean") }}) as jira_ticket_submitted	,
isnull(stg.last_modified_date AT TIME ZONE 'PST','{{ var("default_date") }}') as last_modified_date	,
coalesce(location_of_issue_c,location_of_issues_c	, '{{ var("default_varchar") }}') as location_of_issue	,
isnull(stg.net_suite_link_c, '{{ var("default_varchar") }}') as net_suite_link	,
isnull(stg.netsuite_case_number_c , '{{ var("default_varchar") }}') as netsuite_case_number	,
isnull(stg.netsuite_id_c, '{{ var("default_varchar") }}') as netsuite_id	,
isnull(stg.origin , '{{ var("default_varchar") }}') as origin	,
isnull(stg.owner_id, '{{ var("default_varchar") }}') as owner_id	,
isnull(stg.platform_name_c , '{{ var("default_varchar") }}') as platform_name	,
isnull(stg.priority, '{{ var("default_varchar") }}') as case_priority	,
isnull(stg.product_feedback_submitted_c, {{ var("default_boolean") }}) as product_feedback_submitted	,
isnull(stg.products_c , '{{ var("default_varchar") }}') as products	,
isnull(rt.name , '{{ var("default_varchar") }}') as support_type	,
isnull(stg.round_robin_id_c, {{ var("default_numeric") }}) as round_robin_id	,
isnull(stg.sales_escalation_c , {{ var("default_boolean") }}) as sales_escalation	,
coalesce(solution_c,solutions_c	, '{{ var("default_varchar") }}') as solution	,
isnull(stg.status , '{{ var("default_varchar") }}') as status	,
isnull(stg.subject , '{{ var("default_varchar") }}') as subject	,
isnull(stg.supplied_email , '{{ var("default_varchar") }}') as supplied_email	,
isnull(stg.supplied_name, '{{ var("default_varchar") }}') as supplied_name	,
isnull(stg.survey_send_date_time_c ,'{{ var("default_date") }}') as survey_send_date_time	,
isnull(stg.thread_id_c , '{{ var("default_varchar") }}') as thread_id	,
isnull(stg.type, '{{ var("default_varchar") }}') as case_type	,
isnull(stg.ultimate_parent_account_c, '{{ var("default_varchar") }}') as ultimate_parent_account	,
isnull(stg.validation_account_name_c, '{{ var("default_varchar") }}') as validation_account_name	,
isnull(stg.xcase_number_c , '{{ var("default_varchar") }}') as xcase_number	
from {{ source("fivetran_salesforce_quickstart", "case") }} as stg
left outer join  {{ ref("dim_account") }} as a
on stg.account_id = a.SFDC_account_id
left outer join  {{ source("fivetran_salesforce_quickstart", "record_type") }}  as rt
on stg.record_type_id = rt.id
where stg.is_deleted = false
)
select
  case_id::VARCHAR(300)
 ,account_id::VARCHAR(300)
 ,sfdc_account_id::VARCHAR(300)
 ,account_owner::VARCHAR(400)
 ,account_owner_email::VARCHAR(400)
 ,already_closed::BOOLEAN
 ,case_auto_close_warning_sent::BOOLEAN
 ,case_number::VARCHAR(90)
 ,case_owner_email::VARCHAR(400)
 ,case_ready_to_survey::BOOLEAN
 ,closed_date::TIMESTAMP
 ,codesters_case::BOOLEAN
 ,codesters_classes::DOUBLE PRECISION
 ,codesters_i_2_c_student_avg::DOUBLE PRECISION
 ,codesters_i_2_c_student_completion::DOUBLE PRECISION
 ,codesters_students::DOUBLE PRECISION
 ,confirmed_resolution::BOOLEAN
 ,contact_email::VARCHAR(400)
 ,contact_id::VARCHAR(300)
 ,contact_phone::VARCHAR(120)
 ,created_date::TIMESTAMP
 ,csat_response::VARCHAR(1000)
 ,data_quality_description::VARCHAR(1000)
 ,data_quality_score::INTEGER
 ,description::VARCHAR(max)
 ,initial_response_captured::BOOLEAN
 ,is_closed::BOOLEAN
 ,is_escalated::BOOLEAN
 ,issues::VARCHAR(1000)
 ,jira_ticket_submitted::BOOLEAN
 ,last_modified_date::TIMESTAMP
 ,location_of_issue::VARCHAR(5000)
 ,net_suite_link::VARCHAR(1000)
 ,netsuite_case_number::VARCHAR(1000)
 ,netsuite_id::VARCHAR(300)
 ,origin::VARCHAR(1000)
 ,owner_id::VARCHAR(300)
 ,platform_name::VARCHAR(300)
 ,case_priority::VARCHAR(1000)
 ,product_feedback_submitted::BOOLEAN
 ,products::VARCHAR(5000)
 ,support_type::VARCHAR(240)
 ,round_robin_id::NUMERIC(20,17)
 ,sales_escalation::BOOLEAN
 ,solution::VARCHAR(5000)
 ,status::VARCHAR(100)
 ,subject::VARCHAR(1000)
 ,supplied_email::VARCHAR(400)
 ,supplied_name::VARCHAR(500)
 ,survey_send_date_time::TIMESTAMP
 ,thread_id::VARCHAR(300)
 ,case_type::VARCHAR(100)
 ,ultimate_parent_account::VARCHAR(790)
 ,validation_account_name::VARCHAR(780)
 ,xcase_number::VARCHAR(100)
 ,'{{ var("loaddate") }}'::timestamp as loaddate
from data



