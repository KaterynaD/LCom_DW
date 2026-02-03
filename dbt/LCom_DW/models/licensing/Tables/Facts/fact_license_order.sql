{{ config(
        
        materialized='table',
        dist='organization_district_id',
        sort='startdate'
)
 }}

select 
stg.orderid order_id,
isnull(s.sku_id,   '{{ var("default_ID") }}') as  sku_id,
isnull(a.account_id,   '{{ var("default_ID") }}') as  organization_district_id,
isnull(stg.startdate, '{{ var("default_date") }}')  as startdate,
isnull(stg.expirationdate, '{{ var("default_date") }}') as  expirationdate,
isnull(stg.enforcedaterestrictions, 'y') as enforcedaterestrictions,
isnull(stg.SchoolCount, {{ var("default_numeric") }}) as SchoolCount, 
isnull(stg.StudentCount, {{ var("default_numeric") }}) as StudentCount,
isnull(stg.auditcreatedate, '{{ var("default_date") }}') as  auditcreatedate,
isnull(stg.auditupdatedate, '{{ var("default_date") }}') as auditupdatedate,
'{{ var("loaddate") }}'::timestamp as loaddate,
case when len(stg.netsuiteorderid)<1 or stg.netsuiteorderid is null then '{{ var("default_varchar") }}' else stg.netsuiteorderid end  as netsuite_order_id
from {{ ref("stg_license_orders") }} stg
left outer join {{ ref("dim_account") }} a
on lower(stg.ownerid) = a.lcom_organization_id
left outer join {{ ref("dim_lcom_sku") }} s
on lower(stg.skuid) = s.sku_id
