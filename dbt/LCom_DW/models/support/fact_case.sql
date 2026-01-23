{{
  config(

    materialized='table',    
    sort='created_date', 
    dist='account_id'  ,
    post_hook=['{{ update_FACT_CASE_HISTORY_changed_UK() }}']
    )
}}

with rawdata as (select
{{ safe_select_list_from_profiles(
        table_name='case',
        alias='sfdc_case',
        used_columns=[ 
      'id','account_id','case_number','case_owner_email_c',
'case_ready_to_survey_c','closed_date','confirmed_resolution_c','contact_id',
'created_date','csat_response_c','data_quality_description_c',
'data_quality_score_c','description',
'is_closed','is_escalated','last_modified_date',
'origin','owner_id','platform_name_c','priority',
'round_robin_id_c','status','subject',
'survey_send_date_time_c','thread_id_c','type',
'xcase_number_c','record_type_id','solution_c','is_deleted'
        ],
        profile_src=('profiles','sfdc_schema_audit'),
        base_profile='base',  
        current_profile='current'
    ) }}  
    from {{ source("fivetran_salesforce_quickstart", "case") }} as sfdc_case
)
,data as (
select
stg.id 	 as case_id	,
isnull(a.account_id, '{{ var("default_ID") }}') as account_id	,
isnull(stg.account_id, '{{ var("default_ID") }}') as sfdc_account_id	,
isnull(stg.case_number , '{{ var("default_varchar") }}') as case_number	,
isnull(stg.case_owner_email_c , '{{ var("default_varchar") }}') as case_owner_email	,
isnull(stg.case_ready_to_survey_c , {{ var("default_boolean") }}) as case_ready_to_survey	,
isnull(stg.closed_date ,'{{ var("default_date") }}') as closed_date	,
isnull(stg.confirmed_resolution_c , {{ var("default_boolean") }}) as confirmed_resolution	,
isnull(stg.contact_id , '{{ var("default_ID") }}') as contact_id	,
isnull(stg.created_date	 AT TIME ZONE 'PST','{{ var("default_date") }}') as created_date	,
isnull(stg.csat_response_c , '{{ var("default_varchar") }}') as csat_response	,
isnull(stg.data_quality_description_c , '{{ var("default_varchar") }}') as data_quality_description	,
isnull(stg.data_quality_score_c, {{ var("default_numeric") }}) as data_quality_score	,
isnull(stg.description , '{{ var("default_varchar") }}') as description	,
isnull(stg.is_closed, {{ var("default_boolean") }}) as is_closed	,
isnull(stg.is_escalated, {{ var("default_boolean") }}) as is_escalated	,
isnull(stg.last_modified_date AT TIME ZONE 'PST','{{ var("default_date") }}') as last_modified_date	,
isnull(stg.origin , '{{ var("default_varchar") }}') as origin	,
isnull(stg.owner_id, '{{ var("default_ID") }}') as owner_id	,
isnull(stg.platform_name_c , '{{ var("default_varchar") }}') as platform_name	,
isnull(stg.priority, '{{ var("default_varchar") }}') as case_priority	,
isnull(rt.name , '{{ var("default_varchar") }}') as support_type	,
isnull(stg.round_robin_id_c, {{ var("default_numeric") }}) as round_robin_id	,
isnull(stg.solution_c, '{{ var("default_varchar") }}') as solution	,
isnull(stg.status , '{{ var("default_varchar") }}') as status	,
isnull(stg.subject , '{{ var("default_varchar") }}') as subject	,
isnull(stg.survey_send_date_time_c ,'{{ var("default_date") }}') as survey_send_date_time	,
isnull(stg.thread_id_c , '{{ var("default_varchar") }}') as thread_id	,
isnull(stg.type, '{{ var("default_varchar") }}') as case_type	,
isnull(stg.xcase_number_c , '{{ var("default_varchar") }}') as xcase_number	
from rawdata as stg
left outer join  {{ ref("dim_account") }} as a
on stg.account_id = a.SFDC_account_id
left outer join  {{ source("fivetran_salesforce_quickstart", "record_type") }}  as rt
on stg.record_type_id = rt.id
left outer join {{ source("fivetran_salesforce_quickstart", "contact") }} as c
on stg.contact_id = c.id
where stg.is_deleted = false
)
select
  case_id::VARCHAR(300)
 ,account_id::VARCHAR(300)
 ,sfdc_account_id::VARCHAR(300)
 ,case_number::VARCHAR(90)
 ,case_owner_email::VARCHAR(400)
 ,case_ready_to_survey::BOOLEAN
 ,closed_date::TIMESTAMP
 ,confirmed_resolution::BOOLEAN
 ,contact_id::VARCHAR(300)
 ,created_date::TIMESTAMP
 ,csat_response::VARCHAR(1000)
 ,data_quality_description::VARCHAR(1000)
 ,data_quality_score::INTEGER
 ,description::VARCHAR(max)
 ,is_closed::BOOLEAN
 ,is_escalated::BOOLEAN
 ,last_modified_date::TIMESTAMP
 ,origin::VARCHAR(1000)
 ,owner_id::VARCHAR(300)
 ,platform_name::VARCHAR(300)
 ,case_priority::VARCHAR(1000)
 ,support_type::VARCHAR(240)
 ,round_robin_id::NUMERIC(20,17)
 ,solution::VARCHAR(5000)
 ,status::VARCHAR(100)
 ,subject::VARCHAR(1000)
 ,survey_send_date_time::TIMESTAMP
 ,thread_id::VARCHAR(300)
 ,case_type::VARCHAR(100)
 ,xcase_number::VARCHAR(100)
 ,'{{ var("loaddate") }}'::timestamp as loaddate
from data



