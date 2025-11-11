{{ config(materialized='view',
   bind=False
)
 }}

 select * from {{ source("profiles", "full_to_current_FY_comparing") }}
 union all
 select * from {{ source("profiles", "prev_to_current_FY_comparing") }}
 union all
 select * from {{ source("profiles", "full_to_1_month_ago_comparing") }}
 union all
 select * from {{ source("profiles", "months_comparing") }}