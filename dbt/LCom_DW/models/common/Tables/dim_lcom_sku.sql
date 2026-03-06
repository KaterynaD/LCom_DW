{{ config(
        
        materialized='table',
        dist='all',
        sort='sku_name'
)
 }}

with data as (
select 
lower(sku.skuid) sku_id,
case when sku.skuname ilike '%easy%tech%' then 'EasyTech'  
     when sku.skuname ilike '%techapps%for%texas%' then  'EasyTech' 
     when sku.skuname ilike '%online%safety%' then 'EasyTech'
     when sku.skuname ilike '%keyboarding%' then 'EasyTech'  
     when sku.skuname ilike '%easy%code%' then 'EasyCode'   
     when sku.skuname ilike '%pillars%' then 'EasyCode'
     when sku.skuname ilike '%foundations%' and sku.skuname not ilike '%math%' and sku.skuname not ilike '%science%' then 'EasyCode'     
     else 
        isnull(sku.ProductName,'Other')        
end as sku_group,
case 
when sku.skuname ilike '%techapps%for%texas%' or  sku.skuname ilike '%easyTech%texas%edition%' then  'Tech Apps for Texas'
when sku.skuname = 'Online Safety & Digital Citizenship' then 'Online Safety & Digital Citizenship'
when sku.skuname = 'EasyTech Keyboarding & Word Processing' then 'Keyboarding & Word Processing'
when sku.skuname ilike '%pillars%' then 'EasyCode Pillars'
when sku.skuname ilike '%foundations%' and sku.skuname not ilike '%math%' and sku.skuname not ilike '%science%' then 'EasyCode Foundations'
end as sku_subgroup,
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
union all
select
'{{ var("default_ID") }}' sku_id,
'{{ var("default_varchar") }}' as sku_group,
'{{ var("default_varchar") }}' as sku_subgroup,
'{{ var("default_varchar") }}' as sku_name,
'{{ var("default_varchar") }}' as sku_description,
'{{ var("default_varchar") }}' as parent_sku_id,
'{{ var("default_varchar") }}' as parent_sku_name,
{{ var("default_boolean") }} as is_active,
{{ var("default_boolean") }} as is_valid,
'{{ var("default_date") }}' as auditcreatedate,
 '{{ var("default_date") }}' as auditupdatedate
 from {{ ref('dual') }}
)
select
 sku_id::VARCHAR(50) as sku_id
,sku_group::VARCHAR(200) as sku_group
,isnull(sku_subgroup,sku_group)::VARCHAR(200) as sku_subgroup
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