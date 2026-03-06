{{
    config(

        materialized='table',        
        dist='all', 
        sort='fiscalyear'          
        )
}}

with dim_fiscalyear_raw as
(select 
distinct 
c.fiscalyear,
c.fiscalyear_startdate, 
c.fiscalyear_enddate 
from {{ ref("dim_calendar") }} c 
)
select
fiscalyear, 
isnull(lag(fiscalyear) over (order by fiscalyear_startdate),'{{ var("default_varchar") }}') prev_fiscalyear,
isnull(lead(fiscalyear) over (order by fiscalyear_startdate),'{{ var("default_varchar") }}') next_fiscalyear,
fiscalyear_startdate, 
isnull(lag(fiscalyear_startdate) over (order by fiscalyear_startdate),'{{ var("default_date") }}') prev_fiscalyear_startdate,
isnull(lead(fiscalyear_startdate) over (order by fiscalyear_startdate),'{{ var("default_date") }}') next_fiscalyear_startdate,
fiscalyear_enddate ,
isnull(lag(fiscalyear_enddate) over (order by fiscalyear_startdate),'{{ var("default_date") }}') prev_fiscalyear_enddate,
isnull(lead(fiscalyear_enddate) over (order by fiscalyear_startdate),'{{ var("default_date") }}') next_fiscalyear_enddate
from dim_fiscalyear_raw