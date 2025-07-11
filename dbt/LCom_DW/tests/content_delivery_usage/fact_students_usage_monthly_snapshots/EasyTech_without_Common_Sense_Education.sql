with data1 as (
select
mon_year,
organization_school_id,
school_cnt_students ,
school_students_launches
from {{ ref("fact_students_usage_monthly_snapshots") }}
where product_category = 'EasyTech'
and grade_level='(All)'
and topic='(All)'
)
,data2 as (
select
mon_year,
organization_school_id,
school_cnt_students ,
school_students_launches
from {{ ref("fact_students_usage_monthly_snapshots") }}
where product_category = 'EasyTech without Common Sense Education'
and grade_level='(All)'
and topic='(All)'
)
select
*
from data1
join data2
on data1.mon_year=data2.mon_year
and data1.organization_school_id=data2.organization_school_id
where (data1.school_cnt_students < data2.school_cnt_students
or
data1.school_students_launches < data2.school_students_launches)