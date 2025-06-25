{{ config(materialized='view',
   bind=False
)
 }}




with dim_month as
 (
select distinct FiscalYear, FiscalYear_StartDate, FiscalYear_EndDate, FiscalYear_Mon, Mon_FirstDay, Mon_LastDay,Mon_Year
from {{ source("common","dim_calendar") }}
where mon_year between 202207 and to_char(GetDate(),'yyyymm')
)
,total_active_rawdata as (
select m.Mon_Year, m.Mon_LastDay, sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_year = to_char(m.FiscalYear_StartDate,'yyyymm') 
where include_flg=true
and record_type='Starting'
union
select m.Mon_Year, m.Mon_LastDay,  sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_lastday between m.FiscalYear_StartDate and m.Mon_LastDay
where include_flg=true
and record_type in ('New','Returning')
)
, net_active_rawdata as (
select m.Mon_Year, m.Mon_LastDay,  sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_year = to_char(m.FiscalYear_StartDate,'yyyymm') 
where include_flg=true
and record_type='Starting'
union
select m.Mon_Year, m.Mon_LastDay, sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_lastday between m.FiscalYear_StartDate and m.Mon_LastDay
where include_flg=true
and record_type in ('New','Returning','Returning','ReturningFY' )
except
select m.Mon_Year, m.Mon_LastDay,  sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_lastday between m.FiscalYear_StartDate and m.Mon_LastDay
where include_flg=true
and record_type in ('Churn' )
except
select m.Mon_Year, m.Mon_LastDay, sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_lastday between m.FiscalYear_StartDate and m.Mon_LastDay
where include_flg=true
and record_type in ('NonRenewal','Ghost' )
)
,contract_based_active_data as (
select 
     to_char(LAST_DAY(DATEADD( month, -1, mon_lastday )),'yyyymm')::int  mon_year
    ,LAST_DAY(DATEADD( month, -1, mon_lastday )) Mon_LastDay
	,sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
where include_flg=true
and record_type='Starting'
and mon_year between 202207 and to_char(DATEADD(month,1,GetDate()),'yyyymm')
)
,starting_data as (
select s.Mon_Year, s.Mon_LastDay,  sfdc_ultimate_parent_id
from {{ ref("fact_customers_monthly_snapshots") }} s
join dim_month m
on s.mon_year = to_char(m.FiscalYear_StartDate,'yyyymm') 
where include_flg=true
and record_type='Starting'
)
,all_data as (
select 
     mon_year,
     mon_lastday,
     record_type,
     include_flg,
	 sfdc_ultimate_parent_id	
from {{ ref("fact_customers_monthly_snapshots") }} s
where mon_year between 202206 and to_char(GetDate(),'yyyymm')
and record_type != 'Starting'
)
,data as (
select mon_year,mon_lastday,'Total Active' as record_type, true include_flg, sfdc_ultimate_parent_id from total_active_rawdata
union all
select mon_year,mon_lastday,'Net Active' as record_type, true include_flg,  sfdc_ultimate_parent_id from net_active_rawdata
union all
select mon_year,mon_lastday,'Contract Active' as record_type, true include_flg,  sfdc_ultimate_parent_id from contract_based_active_data
union all
select mon_year,mon_lastday,'Starting' as record_type, true include_flg,  sfdc_ultimate_parent_id from starting_data
union all
select mon_year,mon_lastday, record_type, include_flg,  sfdc_ultimate_parent_id from all_data
)
select
mon_year,
mon_lastday,
record_type, 
include_flg,
sfdc_ultimate_parent_id
from data