{{ config(materialized='view',
   bind=False
)
 }}

 select * from {{ ref("sfdc_full_profiles") }}
 union all
 select * from {{ ref("sfdc_prev_FY_profiles") }}
 union all
 select * from {{ ref("sfdc_current_FY_profiles") }}
 union all
 select * from {{ ref("sfdc_2_months_ago_profiles") }}
 union all
 select * from {{ ref("sfdc_1_month_ago_profiles") }}