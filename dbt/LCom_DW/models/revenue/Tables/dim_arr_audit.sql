{{
    config(

        materialized='table',        
        dist='opportunity_id' 
        
        )
}}


select distinct
mon_year::int,
opportunity_id::varchar(300),
{{ dbt_utils.generate_surrogate_key(['issue','category']) }}::varchar(50) as issue_id
from {{ ref('int_arr_audit') }}
