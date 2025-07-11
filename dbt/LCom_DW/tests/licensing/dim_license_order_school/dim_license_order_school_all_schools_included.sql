select   lower(ord_sch.schoolid) +'___'+ ord_sch.orderid
from {{ ref("stg_license_orders") }}  stg
join {{ source("staging","license_orderschool") }} ord_sch
on stg.orderid = ord_sch.orderid
join {{ source("dbo","organization") }} o
on lower(ord_sch.schoolid) = o.organization_id
where ord_sch.Valid_boolean=true
except 
select  organization_school_id +'___'+ order_id
from {{ ref("dim_license_order_school")}}