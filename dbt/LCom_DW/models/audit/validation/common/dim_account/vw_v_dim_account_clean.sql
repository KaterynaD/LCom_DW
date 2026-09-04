{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select 
account_id
from {{ ref("dim_account") }}
where sfdc_account_id!='{{ var("default_ID") }}'
group by account_id
having count(distinct sfdc_account_id)>1