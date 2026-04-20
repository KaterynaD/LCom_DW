{{
    config(

        materialized='table',        
        dist='all' 
        
        )
}}

select distinct
{{ dbt_utils.generate_surrogate_key(['issue']) }}::varchar(50) as issue_id,
issue::varchar(100),
category::varchar(100)
from {{ ref('int_arr_audit') }}