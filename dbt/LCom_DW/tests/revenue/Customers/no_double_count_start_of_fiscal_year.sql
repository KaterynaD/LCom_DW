--no one in fact_customers_new_monthly_snapshots is in Month Start - no double count at the start of a fiscal year
with dim_month as
(select distinct c.mon_year, c.fiscalyear from common.dim_calendar c )
select
m.fiscalyear,
s.mon_year,
s.sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_year=m.mon_year
where record_type in ('New','Returning','ReturningFY')
and include_flg=True
intersect
select
m.fiscalyear,
s.mon_year,
s.sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_year=m.mon_year
where record_type=('Starting')
and include_flg=True