{{ config(
        
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        dist='organization_district_id',
        sort='startdate'
)
 }}

select 
stg.orderid order_id,
isnull(stg.skuid,   '{{ var("default_ID") }}') as  sku_id,
isnull(a.account_id,   '{{ var("default_ID") }}') as  organization_district_id,
isnull(stg.startdate, '{{ var("default_date") }}')  as startdate,
isnull(stg.expirationdate, '{{ var("default_date") }}') as  expirationdate,
isnull(stg.enforcedaterestrictions, 'y') as enforcedaterestrictions,
isnull(stg.SchoolCount, {{ var("default_numeric") }}) as SchoolCount, 
isnull(stg.StudentCount, {{ var("default_numeric") }}) as StudentCount,
isnull(stg.auditcreatedate, '{{ var("default_date") }}') as  auditcreatedate,
isnull(stg.auditupdatedate, '{{ var("default_date") }}') as auditupdatedate,
'{{ var("loaddate") }}'::timestamp as loaddate
from {{ ref("stg_license_orders") }} stg
left outer join {{ ref("dim_account") }} a
on lower(stg.ownerid) = a.lcom_organization_id
{% if is_incremental() %}
 where coalesce(stg.auditupdatedate,'1900-01-01') >= (select coalesce(max(t.auditupdatedate),'1900-01-01') from {{ this }} t)
{% endif %}