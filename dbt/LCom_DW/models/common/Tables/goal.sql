{{ config(
        
        materialized='table',
        dist='all'
)
 }}

select 
school_or_fiscal_year::varchar(10),
goal_type::varchar(150),
applied_to::varchar(10),
goal_name::varchar(150),
goal::double precision,
attribute1::varchar(150),
loaddate::timestamp
from {{ ref('stg_goal') }}
