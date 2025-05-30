{{
    config(

        materialized='table',        
        sort='sequence_id', 
        dist='even',
        post_hook='{{ create_FK(target.database,model.schema,model.name, "sequence_id","content_delivery_usage","dim_sequence","sequence_id") }}'
 )  
}}

with data as (
select
lower(stg.sequenceid) as sequence_id,
lower(stg.CurriculumItemId) as learning_object_id
from {{ source("staging", "sequence_learning_object") }} stg
join {{ ref("dim_sequence")}} seq
    on lower(stg.sequenceid) = seq.sequence_id
join {{ ref("dim_learning_object")}} lo
    on lower(stg.CurriculumItemId) = lo.learning_object_id
where stg.sequenceid is not null and stg.CurriculumItemId is not null
)
select
sequence_id::varchar(50) as sequence_id,
learning_object_id::varchar(50) as learning_object_id,
'{{ var("loaddate") }}'::timestamp as loaddate
from data
