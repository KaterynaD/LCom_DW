{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select 
ua.user_account_id student_id,
isnull(ua.grade_level_code,'UN') grade_level_code,
ua.organization_district_id organization_district_id,
dist.organization_name DistrictName,
ua.created_datetime created_datetime,
ua.modified_datetime modified_datetime,
ua.deleted_datetime deleted_datetime
from {{ source("dbo","mv_student_account") }} ua
join {{ source("dbo","organization") }} dist
on ua.organization_district_id = dist.organization_id
union all 
/*default*/
select 
'00000000-0000-0000-0000-000000000000' student_id,
'UN' grade_level_code,
'00000000-0000-0000-0000-000000000000' organization_district_id,
'Unknown' district,
null created_datetime,
null modified_datetime,
null deleted_datetime



