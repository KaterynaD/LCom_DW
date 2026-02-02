select
opportunity_id,
count(record_type+'_'+bucket_original) cnt,
count(distinct record_type+'_'+bucket_original) cntD
from {{ ref("fact_revenue_monthly_snapshots") }}
where include_flg=true
and bucket='Sales : Cancellation : ARR'
group by opportunity_id
having cnt!=cntD
order by cntD desc