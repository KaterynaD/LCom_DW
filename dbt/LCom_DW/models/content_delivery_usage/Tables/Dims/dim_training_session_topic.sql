{{
    config(

        materialized='table',        
        sort='topic_id', 
        dist='all' 
        
        )
}}

select distinct
topic_id::varchar(300),
topic::varchar(200)
,'{{ var("loaddate") }}'::TIMESTAMP as loaddate
from {{ ref("stg_topics") }}