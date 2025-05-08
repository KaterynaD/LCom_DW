{{
    config(

        materialized='table',        
        sort='sku_id', 
        dist='all',
        post_hook='{{ create_FK(target.database,model.schema,model.name, "sku_id","common","dim_lcom_sku","sku_id") }}'
 )  
}}

with data as (
select
lower(stg.skuid) as sku_id,
lower(stg.CurriculumItemId) as learning_object_id
from {{ source("staging", "sku_learning_object_v2") }} stg
join {{ ref("dim_lcom_sku")}} sku
    on lower(stg.skuid) = sku.sku_id
join {{ ref("dim_learning_object")}} lo
    on lower(stg.CurriculumItemId) = lo.learning_object_id
where stg.skuid is not null and stg.CurriculumItemId is not null
)
select
sku_id::varchar(50) as sku_id,
learning_object_id::varchar(50) as learning_object_id,
'{{ var("loaddate") }}'::timestamp as loaddate
from data
