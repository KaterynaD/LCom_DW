with dim_month as --Thread to calculate monthly metrics
(select substring(c.mon_year,5,2)::int mon, c.mon_year, c.mon_firstday, c.mon_lastday, c.FiscalYear, c.SchoolYear, c.FiscalYear_startdate, c.FiscalYear_enddate , c.FiscalYear_mon, c.SchoolYear_mon
from {{ ref("dim_month") }} c
where mon_year between 202407 and to_char(GetDate(),'yyyymm')
)
,rawdata as (
select
m.mon,
m.mon_year,
m.mon_lastday ,
m.FiscalYear,
m.FiscalYear_mon,
m.SchoolYear,
m.SchoolYear_mon,
o.account_id,
o.sfdc_account_id,
o.opportunity_id,
o.number_of_students,
o.number_of_schools,
o.start_date,
o.end_date
from dim_month m
join {{ ref("fact_opportunity") }} o
on m.mon_lastday between o.start_date and o.end_date
where o.stage_name='Closed Won'
and o.invoiced_date!='1900-01-01'
and o.sfdc_account_id!='00000000-0000-0000-0000-000000000000'
)
select
mon,
mon_year,
mon_lastday ,
FiscalYear,
FiscalYear_mon,
SchoolYear,
SchoolYear_mon,
account_id,
sfdc_account_id,
max(number_of_students) as number_of_students,
max(number_of_schools) as number_of_schools
from rawdata
group by
mon,
mon_year,
mon_lastday ,
FiscalYear,
FiscalYear_mon,
SchoolYear,
SchoolYear_mon,
account_id,
sfdc_account_id
order by 
account_id,
mon_year