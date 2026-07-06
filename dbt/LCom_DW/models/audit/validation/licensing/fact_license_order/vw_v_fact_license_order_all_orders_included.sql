{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select   lower(ord_sch.schoolid) +'___'+ ord_sch.orderid
from {{ ref("fact_license_order") }}  stg
join {{ source("staging","license_orderschool") }} ord_sch
on stg.order_id = ord_sch.orderid
join {{ source("dbo","organization") }} o
on lower(ord_sch.schoolid) = o.organization_id
where ord_sch.Valid_boolean=true
except 
select  organization_school_id +'___'+ order_id
from {{ ref("dim_license_order_school")}}