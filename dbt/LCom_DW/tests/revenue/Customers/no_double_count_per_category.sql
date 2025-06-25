--each Ultimate Parent can be counted more then once in one and only one category with different opportunity id only
with dim_month as
(select distinct c.mon_year, c.fiscalyear from common.dim_calendar c )
select
m.fiscalyear,
s.mon_year, 
s.record_type, 
count(distinct s.sfdc_ultimate_parent_id+'_'+opportunity_id) cntD,
count(s.sfdc_ultimate_parent_id+'_'+opportunity_id) cnt
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_year=m.mon_year
group by m.fiscalyear,s.mon_year,s.record_type
having count(distinct s.sfdc_ultimate_parent_id+'_'+s.opportunity_id) != count(s.sfdc_ultimate_parent_id+'_'+s.opportunity_id)
order by s.mon_year, s.record_type