{{
  config(

    materialized='table',    
    sort='created_date', 
    dist='account_id'  ,
    post_hook=['{{ update_history_table_changed_uk("support", "fact_case_history") }}']
    )
}}

with rawdata as (select
{{ safe_select_list_from_profiles(
        table_name='case',
        alias='sfdc_case',
        used_columns=[ 
      'id','account_id','case_number','case_owner_email_c',
'closed_date','contact_id',
'created_date','description',
'is_closed','is_escalated','last_modified_date',
'origin','owner_id','platform_name_c','priority',
'status','subject',
'type',
'record_type_id','solution_c','is_deleted'
        ],
        profile_src=('profiles','vw_sfdc_schema_audit'),
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
isnull(stg.closed_date ,'{{ var("default_date") }}') as closed_date	,
isnull(stg.contact_id , '{{ var("default_ID") }}') as contact_id	,
isnull(stg.created_date	 AT TIME ZONE 'PST','{{ var("default_date") }}') as created_date	,
isnull(stg.description , '{{ var("default_varchar") }}') as description	,
isnull(stg.is_closed, {{ var("default_boolean") }}) as is_closed	,
isnull(stg.is_escalated, {{ var("default_boolean") }}) as is_escalated	,
isnull(stg.last_modified_date AT TIME ZONE 'PST','{{ var("default_date") }}') as last_modified_date	,
isnull(stg.origin , '{{ var("default_varchar") }}') as origin	,
isnull(stg.owner_id, '{{ var("default_ID") }}') as owner_id	,
isnull(stg.platform_name_c , '{{ var("default_varchar") }}') as platform_name	,
isnull(stg.priority, '{{ var("default_varchar") }}') as case_priority	,
isnull(rt.name , '{{ var("default_varchar") }}') as support_type	,
isnull(stg.solution_c, '{{ var("default_varchar") }}') as solution	,
isnull(stg.status , '{{ var("default_varchar") }}') as status	,
isnull(stg.subject , '{{ var("default_varchar") }}') as subject	,
isnull(stg.type, '{{ var("default_varchar") }}') as case_type
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
 ,closed_date::TIMESTAMP
 ,contact_id::VARCHAR(300)
 ,created_date::TIMESTAMP
 ,description::VARCHAR(max)
 ,is_closed::BOOLEAN
 ,is_escalated::BOOLEAN
 ,last_modified_date::TIMESTAMP
 ,origin::VARCHAR(1000)
 ,owner_id::VARCHAR(300)
 ,platform_name::VARCHAR(300)
 ,case_priority::VARCHAR(1000)
 ,support_type::VARCHAR(240)
 ,solution::VARCHAR(5000)
 ,status::VARCHAR(100)
 ,subject::VARCHAR(1000)
 ,case_type::VARCHAR(100)
 ,'{{ var("loaddate") }}'::timestamp as loaddate
from data



