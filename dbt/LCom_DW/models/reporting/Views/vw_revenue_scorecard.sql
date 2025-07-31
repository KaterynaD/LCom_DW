{{ config(materialized='view',
   bind=False
)
 }}
with dim_date_prev as (
select distinct FiscalYear, FiscalYear_StartDate, FiscalYear_EndDate,Mon_Year
from {{ source("common","dim_calendar") }}
where FiscalYear_StartDate =  (select  max(FiscalYear_StartDate)  from {{ source("common","dim_calendar") }} where FiscalYear_StartDate<(select FiscalYear_StartDate from {{ source("common","dim_calendar") }} where cal_date=trunc(GetDate())))
and FiscalYear_Mon=12
)
,rawdata as (
select 
'Actual' as category, 
record_type,
bucket,
include_flg,
new_opp_this_fy_flg,
amount,
vrm.FiscalYear,
loaddate last_updated
from {{ ref("vw_fact_revenue_monthly_snapshots") }} vrm 
where vrm.mon_year=to_char(GetDate(), 'yyyymm')::int
union all
select 
'Previous' as category, 
record_type,
bucket,
include_flg,
new_opp_this_fy_flg,
amount,
vrm.FiscalYear,
loaddate last_updated
from {{ ref("vw_fact_revenue_monthly_snapshots") }} vrm 
join dim_date_prev
on  vrm.mon_year = dim_date_prev.Mon_Year
)
,data as (
select 
category,
sum(case when 
record_type='ARR' 
and include_flg
and bucket in ('Sales : Upsell : ARR','Sales : Cancellation : Biz Dev',
'Sales : Reduction : Biz Dev','Sales : Price Increased : ARR',
'Sales : Cancellation : ARR','Sales : Reseller ARR Renewal',
'Sales : Upsell : Biz Dev','Sales : New Business : ARR',
'Sales : New Business : Biz Dev','Sales : Reduction : ARR',
'Sales : Renewal : ARR','Sales : Reseller ARR Upsell',
'Sales : Renewal : Biz Dev','Expected','Sales : Price Increased : Biz Dev'
)
     then amount
     else 0
     end) as ARR,
--
SUM(
case when record_type  in ('ARR') and include_flg and Bucket='Expected' then amount else 0 end +
case when record_type  in ('ARR-MonthlyAdded') and include_flg and  Bucket  in ('Sales : Renewal : Biz Dev','Sales : Renewal : ARR','Sales : Reseller ARR Renewal') then amount else 0 end +
case when record_type  in ('ARR-MonthlyReduced') and include_flg and not new_opp_this_fy_flg then amount else 0 end
)
/
(
 SUM(case when record_type  in ('ARR') and include_flg and Bucket='Expected' then amount else 0 end) + 
 SUM(case when record_type  in ('ARR-MonthlyAdded') and include_flg and  Bucket  in ('Sales : Renewal : Biz Dev','Sales : Renewal : ARR','Sales : Reseller ARR Renewal') then amount else 0 end)
 ) GRR,
--
SUM(
case when record_type  in ('ARR') and include_flg and Bucket='Expected' then amount else 0 end +
case when record_type  in ('ARR-MonthlyAdded') and include_flg and not Bucket  in ('Sales : New Business : Biz Dev','Sales : New Business : ARR') then amount else 0 end +
case when record_type  in ('ARR-MonthlyReduced') and [include_flg] and not new_opp_this_fy_flg then amount else 0 end
)
/
(
 SUM(case when record_type  in ('ARR') and include_flg and Bucket='Expected' then amount else 0 end) + 
 SUM(case when record_type  in ('ARR-MonthlyAdded') and include_flg and  Bucket  in ('Sales : Renewal : Biz Dev','Sales : Renewal : ARR','Sales : Reseller ARR Renewal') then amount else 0 end)
 ) AS NRR,
FiscalYear,
last_updated
from rawdata
group by category, FiscalYear, last_updated
)
select 
category,
ARR,
GRR,
NRR,
FiscalYear,
last_updated
from data
union all
select 
'Target' as category,
26400000 ARR,
1 GRR,
0.9 NRR,
'N/A' FiscalYear,
cast('1900-01-01' as date) last_updated


