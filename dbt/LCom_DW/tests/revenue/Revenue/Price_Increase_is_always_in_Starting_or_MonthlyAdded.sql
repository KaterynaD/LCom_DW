select fr.opportunity_id
from {{ ref("fact_revenue_monthly_snapshots") }} fr
join {{ ref("stg_opportunities_chain_of_renewals")}} ocr
on fr.opportunity_id=ocr.opportunity_id
left outer join
(
select fiscalyear,renewal_opportunity_id
from {{ ref("fact_revenue_monthly_snapshots") }}
where record_type='ARR-MonthlyAdded'
and include_flg=true
union all
select fiscalyear,renewal_opportunity_id
from {{ ref("fact_revenue_monthly_snapshots") }}
where record_type='ARR-Starting'
and include_flg=true
union all	
select fiscalyear,opportunity_id	
from {{ ref("fact_revenue_monthly_snapshots") }}
where record_type='ARR-Starting'	
and include_flg=true
and mon_year>=202507
) data
on data.fiscalyear=fr.fiscalyear
and ocr.parent_opportunities like '%'+ data.renewal_opportunity_id+'%'
--or there is no parent opportunity at all or parent opportunity has 0 ARR (some garbage which we may not need in ARR?)
left outer join {{ ref("fact_opportunity") }} po
on po.renewal_opportunity_id=fr.opportunity_id
where fr.record_type='ARR-MonthlyAdded'
and fr.bucket ilike 'Sales : Price%'
and fr.include_flg=true
and (po.opportunity_id is not null and po.true_arr>0)
and data.renewal_opportunity_id is null
