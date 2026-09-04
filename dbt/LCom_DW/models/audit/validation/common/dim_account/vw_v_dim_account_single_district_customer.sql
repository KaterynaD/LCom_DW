{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}
 
select
conformed_district_id,
count(distinct conformed_customer_id) cnt_customers
from common.dim_account
group by conformed_district_id
having count(distinct conformed_customer_id)>1
order by count(distinct conformed_customer_id) desc