{{ config(materialized='ephemeral') }}


select 
employee_id,
name,
user_role,
case when is_active then 1 else 0 end as is_active,
department,
title,
last_modified_date,
created_date
from {{ ref("dim_employee") }}
