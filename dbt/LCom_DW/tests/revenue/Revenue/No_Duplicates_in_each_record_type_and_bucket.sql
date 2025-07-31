select
mon_year,
record_type,
bucket_original,
count(opportunity_id) cnt,
count(distinct opportunity_id) cntD
from {{ ref("fact_revenue_monthly_snapshots") }}
where include_flg=true
group by
mon_year,
record_type,
bucket_original
having count(opportunity_id)!=count(distinct opportunity_id)
order by count(opportunity_id) - count(distinct opportunity_id) desc
