{{
    config(

        materialized='table',        
        sort='topic_id', 
        dist='all' 
        
        )
}}

select distinct
training_session_id::varchar(300),
topic_id::varchar(300)
,'{{ var("loaddate") }}'::TIMESTAMP as loaddate
from {{ ref("stg_topics") }}