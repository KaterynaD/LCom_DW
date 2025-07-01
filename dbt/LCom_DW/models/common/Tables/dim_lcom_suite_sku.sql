{{
    config(

        materialized='table',        
        sort='suite_id', 
        dist='all',
        post_hook=['{{ create_FK(target.database,model.schema,model.name, "sku_id","common","dim_lcom_sku","sku_id") }}',
                   '{{ create_FK(target.database,model.schema,model.name, "suite_id","common","dim_lcom_suite","suite_id") }}',
        ]
 )  
}}

with data as 
(
    select 
    lower(stg.lcom_suite_id) as suite_id,
    lower(stg.skuid) as sku_id
from {{ source("staging","sku_suite") }} stg
where stg.lcom_suite_id is not null and stg.skuid is not null
)
select
suite_id::varchar(50) as suite_id,
sku_id::varchar(50) as sku_id,
'{{ var("loaddate") }}'::timestamp as loaddate
from data