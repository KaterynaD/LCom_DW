--each Ultimate Parent is counted in only one category each month unless it's Starting and Churn (before expiration)
with dim_month as
(select distinct c.mon_year, c.fiscalyear from common.dim_calendar c )
select
m.fiscalyear,
s.mon_year,
s.sfdc_ultimate_parent_id,
count(distinct s.record_type)
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_year=m.mon_year
where s.include_flg=true
and s.record_type<>'Starting'
group by m.fiscalyear,s.mon_year, s.sfdc_ultimate_parent_id
having count(distinct s.record_type)>1