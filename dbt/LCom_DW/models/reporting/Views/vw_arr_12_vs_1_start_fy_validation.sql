{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}
with data_12_fy_mon as (									
select	
mon_year,
case when sfdc_ultimate_parent_id='00000000-0000-0000-0000-000000000000' then sfdc_account_id else sfdc_ultimate_parent_id end sfdc_ultimate_parent_id,									
sum(r.amount) amount									
from {{ ref('vw_fact_revenue_monthly_snapshots') }} r	
join {{ ref('stg_opportunities_chain_of_renewals') }} socor									
on r.opportunity_id = socor.opportunity_id									
where record_type='ARR'									
and r.include_flg = true			
and r.fiscalyear_mon = 12
group by
mon_year,
case when sfdc_ultimate_parent_id='00000000-0000-0000-0000-000000000000' then sfdc_account_id else sfdc_ultimate_parent_id end									
)									
,starting_1_fy_mon as (									
select		
mon_year,
case when sfdc_ultimate_parent_id='00000000-0000-0000-0000-000000000000' then sfdc_account_id else sfdc_ultimate_parent_id end sfdc_ultimate_parent_id,
sum(r.amount) amount	
from {{ ref('vw_fact_revenue_monthly_snapshots') }} r	
where record_type='ARR-Starting'									
and r.include_flg = true				
and r.fiscalyear_mon = 1
group by		
mon_year,
case when sfdc_ultimate_parent_id='00000000-0000-0000-0000-000000000000' then sfdc_account_id else sfdc_ultimate_parent_id end									
)									
,data AS (									
select	
coalesce(data_12_fy_mon.sfdc_ultimate_parent_id,starting_1_fy_mon.sfdc_ultimate_parent_id) sfdc_ultimate_parent_id,		
data_12_fy_mon.mon_year mon_year_12,
starting_1_fy_mon.mon_year mon_year_1,
case when data_12_fy_mon.sfdc_ultimate_parent_id is null then 'No' else 'Yes' end is_in_12,									
case when starting_1_fy_mon.sfdc_ultimate_parent_id is null then 'No' else 'Yes' end is_in_1,									
isnull(data_12_fy_mon.amount,0) amount_12,									
isnull(starting_1_fy_mon.amount,0) amount_1,									
isnull(data_12_fy_mon.amount,0) - isnull(starting_1_fy_mon.amount,0) as diff									
from data_12_fy_mon									
full outer join									
starting_1_fy_mon									
on data_12_fy_mon.sfdc_ultimate_parent_id = starting_1_fy_mon.sfdc_ultimate_parent_id	
and starting_1_fy_mon.mon_year - data_12_fy_mon.mon_year = 1
)		
select																	
a.sfdc_name,
data.sfdc_ultimate_parent_id,		
data.mon_year_12,
data.mon_year_1,
data.is_in_12,									
data.is_in_1,									
data.amount_12,									
data.amount_1,									
data.diff
from data
join {{ ref('dim_account') }} a
on data.sfdc_ultimate_parent_id = a.sfdc_account_id