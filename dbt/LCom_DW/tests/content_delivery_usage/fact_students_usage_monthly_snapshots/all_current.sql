select schoolyear,unique_students, unique_students_launches from reporting.vw_usage_scorecard vus 
except
select distinct schoolyear, company_cnt_students , company_students_launches 
from {{ ref("fact_students_usage_monthly_snapshots") }}
where mon_year =  to_char(TIMEZONE('UTC', GetDate()),'yyyymm')::int
and topic='(All)'
and grade_level='(All)'
and product_category ='(All)'