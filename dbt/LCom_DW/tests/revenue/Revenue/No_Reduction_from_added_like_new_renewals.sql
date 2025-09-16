select opportunity_id
from {{ ref("fact_revenue_monthly_snapshots") }}
where record_type='ARR-MonthlyAdded'
and bucket ilike '%Renewal%'
and include_flg=true
intersect
select opportunity_id
from {{ ref("fact_revenue_monthly_snapshots") }}
where record_type='ARR-MonthlyReduced'
and bucket ilike 'Sales : Reduction%'
and include_flg=true
