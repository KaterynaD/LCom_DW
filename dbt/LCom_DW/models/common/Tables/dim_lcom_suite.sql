{{
    config(

        materialized='table',        
        sort='suite_id', 
        dist='all'
 )  
}}

with ss as 
(select distinct sfdc_suite_id, lcom_suite_id from {{ source("staging","sku_suite") }})
,data as (
select 
lower(ss.lcom_suite_id) as suite_id,
isnull(lsc.id,'{{ var("default_varchar") }}') as sfdc_suite_id,
case 
when ss.lcom_suite_id='B1BAE5EF-7539-406F-8EF8-4458A97B9AE6' then 'Demo External' /*not sync with SFDC*/
when ss.lcom_suite_id='2EA52DA8-2C0A-4CC4-83FA-FEE8B11ABD81' then 'Demo Training' /*not sync with SFDC*/
else
isnull(lsc.name,'{{ var("default_varchar") }}')
end  as suite_name,
isnull(lsc.created_date AT TIME ZONE 'PST','{{ var("default_date") }}') as created_date,
isnull(lsc.last_modified_date AT TIME ZONE 'PST','{{ var("default_date") }}') as last_modified_date
from ss 
left outer join  {{ source("fivetran_salesforce_quickstart","lcom_suite_c") }} lsc 
on lsc.id=ss.sfdc_suite_id
union all
select 
'{{ var("default_ID") }}' as suite_id,
'{{ var("default_varchar") }}' as sfdc_suite_id,
'{{ var("default_varchar") }}' as suite_name,
'{{ var("default_date") }}'  as created_date,
'{{ var("default_date") }}' as last_modified_date
)
select
suite_id::varchar(50) as suite_id,
sfdc_suite_id::varchar(50) as sfdc_suite_id,
suite_name::varchar(250) as suite_name,
created_date::timestamp as created_date,
last_modified_date::timestamp as last_modified_date,
'{{ var("loaddate") }}'::timestamp as loaddate
from data