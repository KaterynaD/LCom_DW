{{ config(materialized='ephemeral') }}

select 
case_id,
case when is_closed=True then 1 else 0 end as is_closed,
case when is_escalated=True then 1 else 0 end as is_escalated,
closed_date,
case_priority,
account_id,
owner_id,
status,
created_date,
last_modified_date 
from {{ ref("fact_case") }}