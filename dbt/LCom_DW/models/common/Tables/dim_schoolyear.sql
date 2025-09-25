{{
    config(
        materialized='table',        
        dist='all', 
        sort='schoolyear'          
        )
}}

with dim_schoolyear_raw as
(select 
distinct 
c.schoolyear,
c.schoolyear_startdate, 
c.schoolyear_enddate 
from {{ source("common","dim_calendar") }} c 
)
select
schoolyear, 
isnull(lag(schoolyear) over (order by schoolyear_startdate),'{{ var("default_varchar") }}') prev_schoolyear,
isnull(lead(schoolyear) over (order by schoolyear_startdate),'{{ var("default_varchar") }}') next_schoolyear,
schoolyear_startdate, 
isnull(lag(schoolyear_startdate) over (order by schoolyear_startdate),'{{ var("default_date") }}') prev_schoolyear_startdate,
isnull(lead(schoolyear_startdate) over (order by schoolyear_startdate),'{{ var("default_date") }}') next_schoolyear_startdate,
schoolyear_enddate ,
isnull(lag(schoolyear_enddate) over (order by schoolyear_startdate),'{{ var("default_date") }}') prev_schoolyear_enddate,
isnull(lead(schoolyear_enddate) over (order by schoolyear_startdate),'{{ var("default_date") }}') next_schoolyear_enddate
from dim_schoolyear_raw
