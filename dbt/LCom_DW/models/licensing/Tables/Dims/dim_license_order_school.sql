{{ config(
        
        materialized='incremental',
        unique_key=['order_id','organization_school_id'],
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        dist='organization_district_id',
        sort='order_id',
        post_hook='DELETE FROM {{ this }} WHERE order_id in ( select orderid from {{ source("staging","license_order") }} stg where stg.valid_boolean=false)'
)
 }}

select 
ord_sch.orderid order_id,
isnull(dist.account_id,   '{{ var("default_ID") }}') as  organization_district_id,
isnull(sch.account_id,   '{{ var("default_ID") }}') as  organization_school_id,
isnull(ord_sch.auditcreatedate, '{{ var("default_date") }}') as  auditcreatedate,
isnull(ord_sch.auditupdatedate, '{{ var("default_date") }}') as auditupdatedate,
'{{ var("loaddate") }}'::timestamp as loaddate
from {{ ref("stg_license_orders") }}  stg
join {{ source("staging","license_orderschool") }}  ord_sch
on stg.orderid=ord_sch.orderid
--
left outer join {{ ref("dim_account") }} dist
on lower(stg.ownerid) = dist.account_id
--
left outer join {{ ref("dim_account") }} sch
on lower(ord_sch.schoolid) = sch.account_id
--
where ord_sch.Valid_boolean=true
{% if is_incremental() %}
 and coalesce(stg.auditupdatedate,'1900-01-01') >= (select coalesce(max(t.auditupdatedate),'1900-01-01') from {{ this }} t )
{% endif %}