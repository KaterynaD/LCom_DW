{{ config(materialized='view',
   bind=False
)
 }}

select 
ua.user_account_id lcom_user_id,
isnull(ua.district_user_identifier,'Unknown') district_user_identifier,
isnull(ua.username,'Unknown') lcom_username,
isnull(ua.first_name,'Unknown') lcom_first_name,
isnull(ua.last_name,'Unknown') lcom_last_name,
isnull(ua.email,'Unknown') lcom_email,
isnull(ua.grade_level_code,'UN') lcom_grade_level_code,
isnull(ua.roles,'Unknown') lcom_roles,
ua.organization_district_id lcom_organization_district_id,
dist.organization_name lcom_districtname,
isnull(ua.external_sis_id,'Unknown') external_sis_id,
ua.created_datetime lcom_created_datetime,
ua.modified_datetime lcom_modified_datetime,
ua.deleted_datetime lcom_deleted_datetime
from {{ source("dbo","user_account") }} ua
join {{ source("dbo","organization") }} dist
on ua.organization_district_id = dist.organization_id
union all 
/*default*/
select 
'00000000-0000-0000-0000-000000000000' lcom_user_id,
'Unknown' district_user_identifier,
'Unknown' lcom_username,
'Unknown' lcom_first_name,
'Unknown' lcom_last_name,
'Unknown' lcom_email,
'UN' lcom_grade_level_code,
'Unknown' lcom_roles,
'00000000-0000-0000-0000-000000000000' lcom_organization_district_id,
'Unknown' lcom_district,
'Unknown' external_sis_id,
null lcom_created_datetime,
null lcom_modified_datetime,
null lcom_deleted_datetime


