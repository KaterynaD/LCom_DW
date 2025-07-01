{{
    config(

        materialized='table',        
        sort='suite_id', 
        dist='all'
        ]
 )  
}}

with data as 
(
    select 
    lower(stg.lcom_suite_id) as suite_id,
    lower(stg.skuid) as sku_id
from {{ source("staging","sku_suite") }} stg
/*join {{ ref("dim_lcom_sku")}} sku
    on lower(stg.skuid) = sku.sku_id
join {{ ref("dim_lcom_suite")}} suite
    on lower(stg.lcom_suite_id) = suite.suite_id
    */
where stg.lcom_suite_id is not null and stg.skuid is not null
)
select
suite_id::varchar(50) as suite_id,
sku_id::varchar(50) as sku_id,
'{{ var("loaddate") }}'::timestamp as loaddate
from data