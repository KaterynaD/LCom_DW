{{
    config(

        materialized='table',        
        dist='all', 
        sort='mon_year'          
        )
}}

with dim_month_raw as --Thread to calculate monthly metrics 
(select 
distinct 
c.mon_year, 
c.mon_firstday, 
c.mon_lastday, 
c.fiscalyear, 
c.fiscalyear_mon, 
c.fiscalyear_startdate, 
c.fiscalyear_enddate, 
c.schoolyear, 
c.schoolyear_mon, 
c.schoolyear_startdate, 
c.schoolyear_enddate 
from {{ source("common","dim_calendar") }} c 
)
select
mon_year, 
isnull(lag(dmr.mon_year) over (order by dmr.mon_year), {{ var("default_numeric") }}) prev_mon_year,
isnull(lead(dmr.mon_year) over (order by dmr.mon_year), {{ var("default_numeric") }}) next_mon_year,
dmr.mon_firstday, 
isnull(lag(dmr.mon_firstday) over (order by dmr.mon_year), '{{ var("default_date") }}') prev_mon_firstday,
isnull(lead(dmr.mon_firstday) over (order by dmr.mon_year), '{{ var("default_date") }}') next_mon_firstday,
dmr.mon_lastday, 
isnull(lag(dmr.mon_lastday) over (order by dmr.mon_year), '{{ var("default_date") }}') prev_mon_lastday,
isnull(lead(dmr.mon_lastday) over (order by dmr.mon_year), '{{ var("default_date") }}') next_mon_lastday,
dmr.fiscalyear, 
isnull(lag(dmr.fiscalyear) over (order by dmr.mon_year),'{{ var("default_varchar") }}') prev_mon_fiscalyear,
isnull(lead(dmr.fiscalyear) over (order by dmr.mon_year),'{{ var("default_varchar") }}') next_mon_fiscalyear,
dmr.fiscalyear_mon, 
isnull(lag(dmr.fiscalyear_mon) over (order by dmr.mon_year), {{ var("default_numeric") }}) prev_mon_fiscalyear_mon,
isnull(lead(dmr.fiscalyear_mon) over (order by dmr.mon_year), {{ var("default_numeric") }}) next_mon_fiscalyear_mon,
dmr.fiscalyear_startdate, 
isnull(lag(dmr.fiscalyear_startdate) over (order by dmr.mon_year), '{{ var("default_date") }}') prev_mon_fiscalyear_startdate,
isnull(lead(dmr.fiscalyear_startdate) over (order by dmr.mon_year), '{{ var("default_date") }}') next_mon_fiscalyear_startdate,
dmr.fiscalyear_enddate ,
isnull(lag(dmr.fiscalyear_enddate) over (order by dmr.mon_year), '{{ var("default_date") }}') prev_mon_fiscalyear_enddate,
isnull(lead(dmr.fiscalyear_enddate) over (order by dmr.mon_year), '{{ var("default_date") }}') next_mon_fiscalyear_enddate,
dmr.schoolyear, 
isnull(lag(dmr.schoolyear) over (order by dmr.mon_year), '{{ var("default_varchar") }}') prev_mon_schoolyear,
isnull(lead(dmr.schoolyear) over (order by dmr.mon_year), '{{ var("default_varchar") }}') next_mon_schoolyear,
dmr.schoolyear_mon, 
isnull(lag(dmr.schoolyear_mon) over (order by dmr.mon_year), {{ var("default_numeric") }}) prev_mon_schoolyear_mon,
isnull(lead(dmr.schoolyear_mon) over (order by dmr.mon_year), {{ var("default_numeric") }}) next_mon_schoolyear_mon,
dmr.schoolyear_startdate, 
isnull(lag(dmr.schoolyear_startdate) over (order by dmr.mon_year), '{{ var("default_date") }}') prev_mon_schoolyear_startdate,
isnull(lead(dmr.schoolyear_startdate) over (order by dmr.mon_year), '{{ var("default_date") }}') next_mon_schoolyear_startdate,
dmr.schoolyear_enddate ,
isnull(lag(dmr.schoolyear_enddate) over (order by dmr.mon_year), '{{ var("default_date") }}') prev_mon_schoolyear_enddate,
isnull(lead(dmr.schoolyear_enddate) over (order by dmr.mon_year), '{{ var("default_date") }}') next_mon_schoolyear_enddate,
--Prev Fiscal Year
df.prev_fiscalyear,
df.next_fiscalyear,
df.prev_fiscalyear_startdate,
df.next_fiscalyear_startdate,
df.prev_fiscalyear_enddate,
df.next_fiscalyear_enddate,
--Prev School Year
ds.prev_schoolyear,
ds.next_schoolyear,
ds.prev_schoolyear_startdate,
ds.next_schoolyear_startdate,
ds.prev_schoolyear_enddate,
ds.next_schoolyear_enddate
--
from dim_month_raw dmr
join {{ ref("dim_fiscalyear") }} df 
on dmr.fiscalyear = df.fiscalyear
join {{ ref("dim_schoolyear") }} ds 
on dmr.schoolyear = ds.schoolyear