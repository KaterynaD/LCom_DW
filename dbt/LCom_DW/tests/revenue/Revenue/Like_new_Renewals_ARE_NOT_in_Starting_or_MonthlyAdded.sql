select fr.opportunity_id
from {{ ref("fact_revenue_monthly_snapshots") }} fr
join {{ ref("stg_opportunities_chain_of_renewals")}} ocr
on fr.opportunity_id=ocr.opportunity_id
left outer join
(
select fiscalyear,renewal_opportunity_id
from {{ ref("fact_revenue_monthly_snapshots") }}
where record_type='MonthlyAdded'
and bucket ilike 'Sales : New%'
and include_flg=true
union all
select fiscalyear,renewal_opportunity_id
from {{ ref("fact_revenue_monthly_snapshots") }}
where record_type='Starting'
and include_flg=true
) data
on data.fiscalyear=fr.fiscalyear
and ocr.parent_opportunities like '%'+ data.renewal_opportunity_id+'%'
where fr.record_type='MonthlyAdded'
and fr.bucket ilike '%Renewal%'
and fr.include_flg=true
and data.renewal_opportunity_id is not null
