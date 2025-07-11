--Level of the granularity: organization_school_id, mon_year, product_category, grade_level, topic
select
organization_school_id,
count(
mon_year::varchar + '_' +
product_category + '_' +
grade_level + '_' +
topic
) cnt,
count(distinct
mon_year::varchar + '_' +
product_category + '_' +
grade_level + '_' +
topic
) cntD
from {{ ref("fact_students_usage_monthly_snapshots") }} fsums
group by organization_school_id
having cnt<>cntD