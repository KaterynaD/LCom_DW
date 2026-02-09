{{
    config(
        materialized='table',        
        sort='campaign_id', 
        dist='all'                                         
         )
}}
with rawdata as (select
     {{ safe_select_list_from_profiles(
        table_name='campaign',
        alias='sfdc_campaign',
        used_columns=[ 
			'id','name','description','created_date','last_modified_date','owner_id',
'parent_id','start_date','end_date','Status','type','pipe_bucket_c',
'data_quality_description_c','data_quality_score_c','is_deleted'
			],
        profile_src=('profiles','vw_sfdc_schema_audit'),
        base_profile='base',
        current_profile='current'
    ) }}
			from {{ source('fivetran_salesforce_quickstart', 'campaign') }} as sfdc_campaign)
,data as 
(
select 
isnull(r.id,'{{ var("default_ID") }}') as campaign_id,
isnull(r.name,'{{ var("default_varchar") }}') as name,
isnull(r.description,'{{ var("default_varchar") }}') as description,
isnull(r.created_date AT TIME ZONE 'PST','{{ var("default_date") }}') as created_date,
isnull(r.last_modified_date AT TIME ZONE 'PST','{{ var("default_date") }}') as last_modified_date,
isnull(r.owner_id,'{{ var("default_ID") }}') as owner_id,
isnull(e.name,'{{ var("default_varchar") }}') as owner_name,
isnull(r.parent_id,'{{ var("default_ID") }}') as parent_id,
isnull(pr.name,'{{ var("default_varchar") }}') as parent_campaign,
isnull(r.start_date,'{{ var("default_date") }}') as start_date,
isnull(r.end_date,'{{ var("default_date") }}') as end_date,
isnull(r.Status,'{{ var("default_varchar") }}') as campaign_status,
isnull(r.type,'{{ var("default_varchar") }}') as campaign_type,
isnull(r.pipe_bucket_c,'{{ var("default_varchar") }}') as pipe_bucket,
isnull(r.data_quality_description_c,'{{ var("default_varchar") }}') as data_quality_description,
isnull(r.data_quality_score_c,'{{ var("default_numeric") }}') as data_quality_score
from rawdata r
left outer join rawdata pr
on r.parent_id = pr.id
left outer join {{ref('dim_employee') }} e
on r.owner_id = e.employee_id
where r.is_deleted=False
union all
select
'{{ var("default_ID") }}' as campaign_id,
'{{ var("default_varchar") }}' as name,
'{{ var("default_varchar") }}' as description,
'{{ var("default_date") }}' as created_date,
'{{ var("default_date") }}' as last_modified_date,
'{{ var("default_ID") }}' as owner_id,
'{{ var("default_varchar") }}' as owner_name,
'{{ var("default_ID") }}' as parent_id,
'{{ var("default_varchar") }}' as parent_campaign,
'{{ var("default_date") }}' as start_date,
'{{ var("default_date") }}' as end_date,
'{{ var("default_varchar") }}' as campaign_status,
'{{ var("default_varchar") }}' as campaign_type,
'{{ var("default_varchar") }}' as pipe_bucket,
'{{ var("default_varchar") }}' as data_quality_description,
'{{ var("default_numeric") }}' as data_quality_score
)
select
campaign_id::VARCHAR(300)
,name::VARCHAR(400)
,description::VARCHAR(4000)
,created_date::TIMESTAMP WITHOUT TIME ZONE
,last_modified_date::TIMESTAMP WITHOUT TIME ZONE
,owner_id::VARCHAR(300)
,owner_name::VARCHAR(400)
,parent_id::VARCHAR(300)
,parent_campaign::VARCHAR(400)
,start_date::DATE
,end_date::DATE
,campaign_status::VARCHAR(20)
,campaign_type::VARCHAR(50)
,pipe_bucket::VARCHAR(50)
,data_quality_description::VARCHAR(100)
,data_quality_score::INTEGER
,'{{ var("loaddate") }}'::TIMESTAMP WITHOUT TIME ZONE as loaddate
from data  