{{ config(materialized='view',
   bind=False
)
 }}

select 
ca.context_id,
isnull(ca.context_name,'Unknown') context_name,
isnull(ca.context_nickname,'Unknown') context_nickname,
isnull(ca.grade_level_code,'UN') grade_level_code,
isnull(ca.user_primary_teacher_id,'00000000-0000-0000-0000-000000000000') user_primary_teacher_id,
isnull(ta.first_name+ ' ' + ta.last_name, 'Unknown') teacher_full_name,
isnull(ta.email, 'Unknown') teacher_email,
isnull(ca.organization_school_id,'00000000-0000-0000-0000-000000000000') organization_school_id,
isnull(sch.organization_name, 'Unknown') SchoolName,
isnull(ca.organization_district_id,'00000000-0000-0000-0000-000000000000') organization_district_id,
isnull(dist.organization_name, 'Unknown') DistrictName,
isnull(ca.external_sis_id, 'Unknown')  external_sis_id,
isnull(ca.parent_context_id,'00000000-0000-0000-0000-000000000000') parent_context_id,
isnull(pca.context_name,'Unknown') parent_context_name,
isnull(pca.context_nickname,'Unknown') parent_context_nickname,
isnull(pca.grade_level_code,'UN') parent_grade_level_code,
ca.created_datetime,
ca.modified_datetime,
ca.deleted_datetime
from {{ source("dbo","context") }} ca
left outer join {{ source("dbo","organization") }} sch
on ca.organization_school_id=sch.organization_id
left outer join {{ source("dbo","organization") }} dist
on ca.organization_district_id=dist.organization_id
left outer join {{ source("dbo","mv_teacher_account") }} ta
on ca.user_primary_teacher_id = ta.user_account_id
left outer join {{ source("dbo","context") }} pca
on ca.parent_context_id = pca.context_id
union all
/*default*/
select 
'00000000-0000-0000-0000-000000000000' context_id,
'Unknown' context_name,
'Unknown' context_nickname,
'UN' grade_level_code,
'00000000-0000-0000-0000-000000000000' user_primary_teacher_id,
'Unknown' teacher_full_name,
'Unknown' teacher_email,
'00000000-0000-0000-0000-000000000000' organization_school_id,
'Unknown' SchoolName,
'00000000-0000-0000-0000-000000000000' organization_district_id,
'Unknown' DistrictName,
'Unknown'  external_sis_id,
'00000000-0000-0000-0000-000000000000' parent_context_id,
'Unknown' parent_context_name,
'Unknown' parent_context_nickname,
'UN' parent_grade_level_code,
null created_datetime,
null modified_datetime,
null deleted_datetime


