--Churn and NonRenewal are counted only if they are present in this fiscal year as customers
--can not easily add month year and fiscal year
with dim_month as
 (
select distinct FiscalYear, FiscalYear_StartDate, FiscalYear_EndDate, FiscalYear_Mon, Mon_FirstDay, Mon_LastDay,Mon_Year
from common.dim_calendar
where TIMEZONE('UTC', GetDate()) between Mon_FirstDay and Mon_LastDay
)
select
sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_lastday between m.FiscalYear_StartDate and m.FiscalYear_EndDate
where include_flg=true
and record_type in ('Churn','NonRenewal', 'Ghost' )
except
select
sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_lastday between m.FiscalYear_StartDate and m.FiscalYear_EndDate
where include_flg=true
and record_type='Starting'