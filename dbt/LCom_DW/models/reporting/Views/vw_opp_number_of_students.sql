{{ config(materialized='view', bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]) }}

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
on o.start_date between m.FiscalYear_startdate and FiscalYear_enddate
where 
o.amount > 0
and o.name like '%NCDPI%'
and o.stage_name not ilike '%lost%'
and o.sfdc_account_id!='{{ var("default_ID") }}'
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
sum(number_of_students) as number_of_students,
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