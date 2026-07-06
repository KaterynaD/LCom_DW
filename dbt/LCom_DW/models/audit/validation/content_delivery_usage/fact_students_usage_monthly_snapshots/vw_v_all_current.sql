{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select schoolyear,unique_students, unique_students_launches from {{ ref("vw_usage_scorecard") }} vus where category='Actual'
except
select distinct schoolyear, company_cnt_students , company_students_launches 
from {{ ref("fact_students_usage_monthly_snapshots") }}
where mon_year =  to_char(TIMEZONE('UTC', GetDate()),'yyyymm')::int
and topic='(All)'
and grade_level='All Students'
and product_category ='(All)'