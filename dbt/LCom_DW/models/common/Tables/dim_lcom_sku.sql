{{ config(
        
        materialized='incremental',
        unique_key=['sku_id'],
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        dist='all',
        sort='sku_name'
)
 }}

with data as (
select 
lower(sku.skuid) sku_id,
case when sku.skuname ilike '%easy%tech%' then 'EasyTech'
     when sku.skuname ilike '%easy%code%' then 'EasyCode'     
     else isnull(sku.ProductName,'{{ var("default_varchar") }}')
end as product_line,
case 
when sku.skuname ilike '%online%safety%' then 'Online Safety'
when sku.skuname ilike '%keyboarding%' then 'Keyboarding'
when sku.skuname ilike '%easy%code%pillars%' then 'EasyCode Pillars'
when sku.skuname ilike '%easy%code%foundations%' then 'EasyCode Foundations'
end as product_name,
isnull(sku.skuname,'{{ var("default_varchar") }}') as sku_name,
isnull(sku.description,'{{ var("default_varchar") }}') as sku_description,
isnull(sku.parentskuid,'{{ var("default_varchar") }}') as parent_sku_id,
isnull(p.skuname,'{{ var("default_varchar") }}') as parent_sku_name,
isnull(sku.isactive,{{ var("default_boolean") }}) as is_active,
isnull(sku.valid,{{ var("default_boolean") }}) as is_valid,
isnull(sku.auditcreatedate,'{{ var("default_date") }}') as auditcreatedate,
isnull(sku.auditupdatedate, '{{ var("default_date") }}') as auditupdatedate
from {{ source("staging","sku") }} sku
left outer join {{ source("staging","sku") }} p
on sku.parentskuid=p.skuid
{% if is_incremental() %}
where coalesce(sku.auditupdatedate,'1900-01-01') >= (select coalesce(max(t.auditupdatedate),'1900-01-01') from {{ this }}  t)
{% endif %}
{% if not is_incremental() %}
union all
select
'{{ var("default_ID") }}' sku_id,
'{{ var("default_varchar") }}' as product_line,
'{{ var("default_varchar") }}' as product_name,
'{{ var("default_varchar") }}' as sku_name,
'{{ var("default_varchar") }}' as sku_description,
'{{ var("default_varchar") }}' as parent_sku_id,
'{{ var("default_varchar") }}' as parent_sku_name,
{{ var("default_boolean") }} as is_active,
{{ var("default_boolean") }} as is_valid,
'{{ var("default_date") }}' as auditcreatedate,
 '{{ var("default_date") }}' as auditupdatedate
{% endif %}
)
select
 sku_id::VARCHAR(50) as sku_id
,product_line::VARCHAR(200) as product_line
,isnull(product_name,product_line)::VARCHAR(200) as product_name
,sku_name::VARCHAR(150) as sku_name
,sku_description::VARCHAR(1100) as sku_description
,parent_sku_id::VARCHAR(100) as parent_sku_id
,parent_sku_name::VARCHAR(150) as parent_sku_name
,is_active::BOOLEAN as is_active
,is_valid::BOOLEAN as   is_valid
,auditcreatedate::TIMESTAMP as auditcreatedate
,auditupdatedate::TIMESTAMP as auditupdatedate
,'{{ var("loaddate") }}'::timestamp as loaddate
from data