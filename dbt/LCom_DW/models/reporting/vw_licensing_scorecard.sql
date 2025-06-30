{{ config(materialized='view', bind=False) }}


with 
dim_date as (
select distinct SchoolYear, SchoolYear_StartDate, SchoolYear_EndDate, SchoolYear_Mon, Mon_FirstDay, Mon_LastDay,Mon_Year
from {{ source("common","dim_calendar") }}
where trunc(GetDate()) between Mon_FirstDay and Mon_LastDay
)
,dim_date_prev as (
select distinct SchoolYear, SchoolYear_StartDate, SchoolYear_EndDate, SchoolYear_Mon, Mon_FirstDay, Mon_LastDay,Mon_Year
from {{ source("common","dim_calendar") }}
where  date_add('year', -1, trunc(GetDate())) between Mon_FirstDay and Mon_LastDay
)
,rawdata as (select
a.account_id,
flo.sku_id,
sum(schoolcount) sum_schools,
sum(studentcount) sum_students
from {{ ref("fact_license_order") }} flo 
join {{ ref("dim_account") }} a
on flo.organization_district_id = a.account_id
where ( trunc(GETDATE()) between startdate and expirationdate
or enforcedaterestrictions = 'n')
and a.lcom_trial=false 
and a.lcom_demo=false
group by a.account_id,
flo.sku_id 
)
, data as (select
account_id,
max(sum_schools) max_schools,
max(sum_students) max_students
from rawdata
group by account_id
)
,datedata as (select greatest(max(auditcreatedate), max(auditupdatedate)) last_updated from {{ ref("fact_license_order") }} flo)
,vw_licensing_scorecard as(
select 
count(distinct account_id) cnt_districts,
sum(max_schools) cnt_schools,
sum(max_students) cnt_students,
dim_date.SchoolYear,
datedata.last_updated
from data
join datedata
on 1=1
join dim_date
on 1=1
group by last_updated,dim_date.SchoolYear
)
select 
'Actual' as category,
cnt_districts,
cnt_schools,
cnt_students,
SchoolYear,
last_updated
from vw_licensing_scorecard
union all
select 
'Previous' as category, 
count(distinct organization_district_id) as cnt_districts, 
sum(schoolcount) as cnt_school, 
sum(studentcount) as cnt_students,
dim_date_prev.SchoolYear,
vlm.mon_lastday last_updated
from {{ ref("vw_licensing_monthly") }} vlm 
join dim_date_prev
on  vlm.mon_year = dim_date_prev.Mon_Year
where sku_name='(All)'
group by vlm.mon_lastday,dim_date_prev.SchoolYear
union all
select 
'Target' as category,
0 as cnt_districts, 
0 as cnt_school, 
0 as cnt_students,
'N/A' FiscalYear,
cast('1900-01-01' as date) last_updated