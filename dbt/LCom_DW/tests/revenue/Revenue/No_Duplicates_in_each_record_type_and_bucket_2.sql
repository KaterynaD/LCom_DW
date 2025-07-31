select
opportunity_id,
count(mon_year::varchar+'_'+record_type+'_'+bucket_original) cnt,
count(distinct mon_year::varchar+'_'+record_type+'_'+bucket_original) cntD
from {{ ref("fact_revenue_monthly_snapshots") }}
where include_flg=true
and bucket_original='Sales : Reduction : ARR'
group by opportunity_id
having cnt!=cntD
order by cntD desc

