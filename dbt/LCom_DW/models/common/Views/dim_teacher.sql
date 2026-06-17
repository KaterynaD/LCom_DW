{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select 
ua.user_account_id teacher_id,
isnull(ua.first_name,'Unknown') first_name,
isnull(ua.last_name,'Unknown') last_name,
isnull(ua.email,'Unknown') email,
ua.organization_district_id organization_district_id,
dist.organization_name DistrictName,
ua.created_datetime created_datetime,
ua.modified_datetime modified_datetime,
ua.deleted_datetime deleted_datetime
from {{ source("dbo","mv_teacher_account") }} ua
join {{ source("dbo","organization") }} dist
on ua.organization_district_id = dist.organization_id
union all 
/*default*/
select 
'00000000-0000-0000-0000-000000000000' teacher_id,
'Unknown' first_name,
'Unknown' last_name,
'Unknown' email,
'00000000-0000-0000-0000-000000000000' organization_district_id,
'Unknown' districtname,
null created_datetime,
null modified_datetime,
null deleted_datetime



