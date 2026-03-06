{{ config(
        
        materialized='table',
        dist='organization_district_id',
        sort='order_id'
)
 }}

select 
ord_sch.orderid order_id,
o.organization_district_id as  organization_district_id,
isnull(sch.account_id,   '{{ var("default_ID") }}') as  organization_school_id,
isnull(ord_sch.auditcreatedate, '{{ var("default_date") }}') as  auditcreatedate,
isnull(ord_sch.auditupdatedate, '{{ var("default_date") }}') as auditupdatedate,
'{{ var("loaddate") }}'::timestamp as loaddate
from {{ ref("fact_license_order") }}  o
join {{ source("staging","license_orderschool") }}  ord_sch
on o.order_id=ord_sch.orderid
--
left outer join {{ ref("dim_account") }} sch
on lower(ord_sch.schoolid) = sch.account_id
--
where ord_sch.Valid_boolean=true
