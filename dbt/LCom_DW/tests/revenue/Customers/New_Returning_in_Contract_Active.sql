--Each New/Returning 
--Present in Contract Based Active (next month Starting)
--Unless there is End Date < Invoice Date (Used without invoice and pay)
--can not easily add fiscal year in the output
with dim_month as --Thread to calculate monthly metrics
(select distinct c.mon_year, c.mon_firstday, c.mon_lastday, c.fiscalyear, c.fiscalyear_startdate from common.dim_calendar c where c.mon_year > 202405)
select
s.mon_year,
s.sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on m.mon_year = s.mon_year
join revenue.fact_opportunity fo
on fo.opportunity_id=s.opportunity_id
and fo.invoiced_date<=fo.end_date
where include_flg=true
and record_type in ('New','Returning','ReturningFY')
except
select
to_char(date_add('month',-1, s.mon_lastday),'yyyymm')::int mon_year,
s.sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on m.mon_lastday = last_day(date_add('month',-1, s.mon_lastday))
where include_flg=true
and record_type='Starting'