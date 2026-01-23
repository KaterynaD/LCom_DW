{{
    config(
        materialized='table',        
        sort='contact_id', 
        dist='account_id'        ,
        post_hook=['{{ update_DIM_CONTACT_HISTORY_changed_UK() }}' ]                                         
         )
}}
with rawdata as (select
     {{ safe_select_list_from_profiles(
        table_name='contact',
        alias='sfdc_contact',
        used_columns=[ 
			'id','name','first_name','last_name','email','phone','title','lead_status_c',
'source_campaign_c','created_date','last_activity_date','last_modified_date',
'account_id','contact_state_c','mailing_state','mailing_state_code',
'other_state','owner_id','is_deleted','key_contact_c','mql_type_c',
'qualifying_date_hubspot_c','returned_date_hubspot_c','rejected_date_hubspot_c',
'sql_date_hubspot_c','mql_date_c','qualifying_date_c','returned_date_c','rejected_date_c','sql_date_c'
			],
        profile_src=('profiles','sfdc_schema_audit'),
        base_profile='base',
        current_profile='current'
    ) }}
			from {{ source('fivetran_salesforce_quickstart', 'contact') }} as sfdc_contact)
,data as 
(
    select
isnull(r.id,'{{ var("default_ID") }}') as contact_id, 
isnull(r.name,'{{ var("default_varchar") }}') as name,  
isnull(r.first_name,'{{ var("default_varchar") }}') as first_name,
isnull(r.last_name,'{{ var("default_varchar") }}') as last_name, 
isnull(a.account_id,'{{ var("default_ID") }}') as account_id,
isnull(a.sfdc_account_id,'{{ var("default_ID") }}') as sfdc_account_id,
isnull(a.sfdc_name,'{{ var("default_varchar") }}') as sfdc_account_name, 
isnull(a.lcom_organization_id,'{{ var("default_varchar") }}') as lcom_organization_id,
isnull(a.lcom_organization_name,'{{ var("default_varchar") }}') as lcom_organization_name,
isnull(r.contact_state_c,'{{ var("default_varchar") }}') as contact_state, 
isnull(r.created_date AT TIME ZONE 'PST','{{ var("default_date") }}') as created_date, 
isnull(r.email,'{{ var("default_varchar") }}') as email, 
isnull(r.key_contact_c,{{ var("default_boolean") }}) as key_contact, 
isnull(r.last_activity_date,'{{ var("default_date") }}') as last_activity_date, 
isnull(r.last_modified_date AT TIME ZONE 'PST','{{ var("default_date") }}') as last_modified_date, 
isnull(r.lead_status_c,'{{ var("default_varchar") }}') as lead_status, 
isnull(r.mailing_state,'{{ var("default_varchar") }}') as mailing_state, 
isnull(r.mailing_state_code,'{{ var("default_varchar") }}') as mailing_state_code, 
isnull(r.mql_type_c,'{{ var("default_varchar") }}') as mql_type, 
isnull(r.other_state,'{{ var("default_varchar") }}') as other_state, 
isnull(r.owner_id,'{{ var("default_ID") }}') as owner_id, 
isnull(e.name,'{{ var("default_varchar") }}') as owner_name,
isnull(e.name,'{{ var("default_varchar") }}') as owner_user_role,
isnull(r.phone,'{{ var("default_varchar") }}') as phone, 
isnull(r.title,'{{ var("default_varchar") }}') as title,
isnull(r.source_campaign_c,'{{ var("default_varchar") }}') as source_campaign, 
isnull(r.qualifying_date_hubspot_c,'{{ var("default_date") }}') as qualifying_date_hubspot, 
isnull(r.rejected_date_hubspot_c,'{{ var("default_date") }}') as rejected_date_hubspot, 
isnull(r.returned_date_hubspot_c,'{{ var("default_date") }}') as returned_date_hubspot, 
isnull(r.sql_date_hubspot_c,'{{ var("default_date") }}') as sql_date_hubspot,
isnull(r.mql_date_c,'{{ var("default_date") }}') as mql_date,
isnull(r.qualifying_date_c,'{{ var("default_date") }}') as qualifying_date,
isnull(r.returned_date_c,'{{ var("default_date") }}') as returned_date,
isnull(r.rejected_date_c,'{{ var("default_date") }}') as rejected_date,
isnull(r.sql_date_c,'{{ var("default_date") }}') as sql_date
from rawdata as r
    left outer join {{ref('dim_account') }} as a
        on r.account_id = a.sfdc_account_id
    left outer join {{ref('dim_employee') }} as e
        on r.owner_id = e.employee_id       
    where r.is_deleted=False
union all
select
'{{ var("default_ID") }}' as contact_id, 
'{{ var("default_varchar") }}' as name,    
'{{ var("default_varchar") }}' as first_name,
'{{ var("default_varchar") }}' as last_name, 
'{{ var("default_ID") }}' as account_id,
'{{ var("default_ID") }}' as sfdc_account_id,
'{{ var("default_varchar") }}' as sfdc_account_name, 
'{{ var("default_varchar") }}' as lcom_organization_id,
'{{ var("default_varchar") }}' as lcom_organization_name,
'{{ var("default_varchar") }}' as contact_state, 
'{{ var("default_date") }}' as created_date, 
'{{ var("default_varchar") }}' as email, 
 {{ var("default_boolean") }} as key_contact, 
'{{ var("default_date") }}' as last_activity_date, 
'{{ var("default_date") }}' as last_modified_date, 
'{{ var("default_varchar") }}' as lead_status, 
'{{ var("default_varchar") }}' as mailing_state, 
'{{ var("default_varchar") }}' as mailing_state_code, 
'{{ var("default_varchar") }}' as mql_type, 
'{{ var("default_varchar") }}' as other_state, 
'{{ var("default_ID") }}' as owner_id, 
'{{ var("default_varchar") }}' as owner_name,
'{{ var("default_varchar") }}' as owner_user_role,
'{{ var("default_varchar") }}' as phone, 
'{{ var("default_varchar") }}' as title,
'{{ var("default_varchar") }}' as source_campaign, 
'{{ var("default_date") }}' as qualifying_date_hubspot, 
'{{ var("default_date") }}' as rejected_date_hubspot, 
'{{ var("default_date") }}' as returned_date_hubspot, 
'{{ var("default_date") }}' as sql_date_hubspot,
'{{ var("default_date") }}' as mql_date,
'{{ var("default_date") }}' as qualifying_date,
'{{ var("default_date") }}' as returned_date,
'{{ var("default_date") }}' as rejected_date,
'{{ var("default_date") }}' as sql_date
)
select
     contact_id::VARCHAR(300)
	,name::VARCHAR(400)
	,first_name::VARCHAR(120)
	,last_name::VARCHAR(240)
	,account_id::VARCHAR(300)
	,sfdc_account_id::VARCHAR(300)
	,sfdc_account_name::VARCHAR(780)
	,lcom_organization_id::VARCHAR(300)
	,lcom_organization_name::VARCHAR(270)
	,contact_state::VARCHAR(25)
	,created_date::TIMESTAMP WITHOUT TIME ZONE
	,email::VARCHAR(240)
	,key_contact::BOOLEAN
	,last_activity_date::DATE
	,last_modified_date::TIMESTAMP WITHOUT TIME ZONE
	,lead_status::VARCHAR(10)
	,mailing_state::VARCHAR(240)
	,mailing_state_code::VARCHAR(30)
	,mql_type::VARCHAR(765)
	,other_state::VARCHAR(240)
	,owner_id::VARCHAR(18)
	,owner_name::VARCHAR(400)
	,owner_user_role::VARCHAR(400)
	,phone::VARCHAR(120)
	,title::VARCHAR(384)
	,source_campaign::VARCHAR(765)	
	,qualifying_date_hubspot::DATE
	,rejected_date_hubspot::DATE
	,returned_date_hubspot::DATE
	,sql_date_hubspot::DATE
	,mql_date::DATE
	,qualifying_date::DATE
	,returned_date::DATE
	,rejected_date::DATE
    ,sql_date::DATE
    ,'{{ var("loaddate") }}'::TIMESTAMP WITHOUT TIME ZONE as loaddate
from data  