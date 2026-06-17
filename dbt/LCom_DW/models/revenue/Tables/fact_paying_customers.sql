{{
    config(

        materialized='incremental',
        unique_key='mon_year',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns',
        dist='account_id',
        sort='mon_year'
        
        )
}}

--Depracate soon
with dim_month as			
(			
select FiscalYear, FiscalYear_StartDate, FiscalYear_EndDate, FiscalYear_Mon, Mon_FirstDay, Mon_LastDay,Mon_Year			
from {{ ref("dim_month") }}			
where mon_year between 201507 and to_char(GetDate(),'yyyymm')			
)			
/*---------------------------------------------------------------------------------------------------------------------------------------*/			
/*---------------------------------------------------------------------------------------------------------------------------------------*/			
,contract_based_active_data as (			
select			
sfdc_ultimate_parent_id ,			
fiscalyear,			
mon_year,			
mon_lastday			
from {{ ref("stg_contract_active") }}  eam			
where mon_year<=to_char(GetDate(),'yyyymm')::int			
and record_type='Contract Active'			
group by			
sfdc_ultimate_parent_id ,			
fiscalyear,			
mon_year,			
mon_lastday			
having max(case when eam.amount>0 then 1 else 0 end) = 1			
)			
/*---------------------------------------------------------------------------------------------------------------------------------------*/			
/*---------------------------------------------------------------------------------------------------------------------------------------*/			
,Churn as (			
select distinct			
vfrms.mon_year,			
vfrms.mon_lastday,			
vfrms.fiscalyear,			
vfrms.sfdc_ultimate_parent_id,			
'Churn' record_type,			
vfrms.include_flg			
from			
{{ ref("vw_fact_revenue_monthly_snapshots") }} vfrms			
--Current Renewal ARR (historical) 			
join {{ ref("dim_account_history") }} ah			
on ah.sfdc_account_id = vfrms.sfdc_ultimate_parent_id			
and dateadd(minute,24*60-1,vfrms.mon_lastday) between ah.fromdate and ah.todate			
-- 			
where vfrms.record_type='ARR-MonthlyReduced'			
and vfrms.bucket like '%Cancel%'			
--there are no active renewal opportunities for this ultimate parent account 			
--or any other active opportunities 			
and ah.sfdc_ultimate_parent_current_renewal_arr = 0			
group by			
vfrms.mon_year,			
vfrms.mon_lastday,			
vfrms.fiscalyear,			
vfrms.sfdc_ultimate_parent_id,			
vfrms.include_flg			
having max(case when abs(vfrms.amount)>0 then 1 else 0 end) = 1			
)			
/*---------------------------------------------------------------------------------------------------------------------------------------*/			
/*---------------------------------------------------------------------------------------------------------------------------------------*/			
,Starting as (			
select			
vfrms.mon_year,			
vfrms.mon_lastday,			
vfrms.fiscalyear,			
vfrms.sfdc_ultimate_parent_id,			
'Starting' record_type			
from			
{{ ref("vw_fact_revenue_monthly_snapshots") }} vfrms			
where vfrms.record_type='ARR-Starting'			
group by			
vfrms.mon_year,			
vfrms.mon_lastday,			
vfrms.fiscalyear,			
vfrms.sfdc_ultimate_parent_id			
having max(case when vfrms.amount>0 then 1 else 0 end) = 1			
)			
/*---------------------------------------------------------------------------------------------------------------------------------------*/			
/*---------------------------------------------------------------------------------------------------------------------------------------*/			
,MonthlyAdded as (			
select			
vfrms.mon_year,			
vfrms.mon_lastday,			
vfrms.fiscalyear,			
vfrms.sfdc_ultimate_parent_id			
from			
{{ ref("vw_fact_revenue_monthly_snapshots") }} vfrms			
where vfrms.record_type='ARR-MonthlyAdded'			
and vfrms.include_flg = true			
group by			
vfrms.mon_year,			
vfrms.mon_lastday,			
vfrms.fiscalyear,			
vfrms.sfdc_ultimate_parent_id			
having max(case when vfrms.amount>0 then 1 else 0 end) = 1			
)			
/*---------------------------------------------------------------------------------------------------------------------------------------*/			
/*---------------------------------------------------------------------------------------------------------------------------------------*/			
,new_and_returning_raw as (			
select distinct			
vfrms.FiscalYear,			
vfrms.mon_year,			
vfrms.mon_lastday,			
vfrms.sfdc_ultimate_parent_id,			
case			
--first FY customer			
when prev_fy.sfdc_ultimate_parent_id is null then 'New'			
else 'Returning'			
-- 			
end as record_type,			
true include_flg,			
vfrms.amount			
from			
{{ ref("vw_fact_revenue_monthly_snapshots") }} vfrms			
--if included in Starting it is not New or Returning, unless it was Churned after Starting 			
left outer join Starting s			
on vfrms.sfdc_ultimate_parent_id = s.sfdc_ultimate_parent_id			
and vfrms.fiscalyear = s.fiscalyear			
-- 			
--if included in MonthlyAdded it is not New or Returning, unless it was Churned after MonthlyAdded			
left outer join MonthlyAdded ma			
on vfrms.sfdc_ultimate_parent_id = ma.sfdc_ultimate_parent_id			
and vfrms.fiscalyear = ma.fiscalyear			
and vfrms.mon_year > ma.mon_year			
-- 			
--Was it Churned this fiscalyear? 			
left outer join			
(			
select			
fiscalyear,			
sfdc_ultimate_parent_id,			
max(mon_lastday) last_churned_mon_lastday			
from Churn			
where include_flg=True			
group by fiscalyear,sfdc_ultimate_parent_id			
) c			
on vfrms.sfdc_ultimate_parent_id = c.sfdc_ultimate_parent_id			
and vfrms.fiscalyear = c.fiscalyear			
--			
--Was it present in ARR previous fiscal years?			
left outer join			
(			
select			
fiscalyear,			
sfdc_ultimate_parent_id,			
max(mon_lastday) last_present_mon_lastday			
from {{ ref("vw_fact_revenue_monthly_snapshots") }}		
where record_type='ARR'			
and include_flg=true			
group by			
fiscalyear,			
sfdc_ultimate_parent_id			
) prev_fy			
on vfrms.sfdc_ultimate_parent_id = prev_fy.sfdc_ultimate_parent_id			
and vfrms.fiscalyear != prev_fy.fiscalyear			
and vfrms.mon_lastday > prev_fy.last_present_mon_lastday			
--			
-- 			
where vfrms.record_type='ARR-MonthlyAdded'			
and vfrms.include_flg = true			
--if included in Starting it is not new or Returning 			
--Can be in Starting, Churned and then MonthlyAdded back 			
and (s.sfdc_ultimate_parent_id is null			
or (s.sfdc_ultimate_parent_id is not null and s.mon_lastday<=c.last_churned_mon_lastday and c.last_churned_mon_lastday<=vfrms.mon_lastday)			
)			
--if included in MonthlyAdded it is not New 			
and (ma.sfdc_ultimate_parent_id is null			
or (ma.sfdc_ultimate_parent_id is not null and ma.mon_lastday<=c.last_churned_mon_lastday and c.last_churned_mon_lastday<=vfrms.mon_lastday)			
)			
)			
,new_and_returning as (			
select			
FiscalYear,			
mon_year,			
mon_lastday,			
record_type,			
include_flg,			
sfdc_ultimate_parent_id			
from new_and_returning_raw			
group by			
FiscalYear,			
mon_year,			
mon_lastday,			
record_type,			
include_flg,			
sfdc_ultimate_parent_id			
having max(case when amount>0 then 1 else 0 end) = 1			
)			
/*---------------------------------------------------------------------------------------------------------------------------------------*/			
/*---------------------------------------------------------------------------------------------------------------------------------------*/			
, net_active_data as (			
select			
m.FiscalYear,			
m.mon_year,			
m.Mon_LastDay,			
s.sfdc_ultimate_parent_id			
from starting s			
join dim_month m			
on s.mon_lastday between m.FiscalYear_StartDate and m.Mon_LastDay			
union			
select			
m.FiscalYear,			
m.mon_year,			
m.Mon_LastDay,			
s.sfdc_ultimate_parent_id			
from new_and_returning s			
join dim_month m			
on s.mon_lastday between m.FiscalYear_StartDate and m.Mon_LastDay			
except			
select			
m.FiscalYear,			
m.Mon_Year,			
m.Mon_LastDay,			
s.sfdc_ultimate_parent_id			
from churn s			
left outer join new_and_returning nr			
on s.sfdc_ultimate_parent_id = nr.sfdc_ultimate_parent_id			
and s.fiscalyear = nr.fiscalyear			
and s.mon_year < nr.mon_year			
join dim_month m			
--from the month of Churn till the end of FY (FY Start Date changed when the new FY starts and churn month is less then it)			
on s.mon_lastday between m.FiscalYear_StartDate and m.Mon_LastDay			
--till New/Returning Month or End of FY			
--we do NOT need to include the month of a new but if it's null we need to include the last month of the fiscal year			
and m.Mon_LastDay < isnull(nr.mon_lastday, dateadd(day, 1,m.fiscalyear_enddate))			
where s.include_flg=true						
)			
/*---------------------------------------------------------------------------------------------------------------------------------------*/			
/*---------------------------------------------------------------------------------------------------------------------------------------*/			
,total_active_data as (			
select			
m.FiscalYear,			
m.mon_year,			
m.Mon_LastDay,			
s.sfdc_ultimate_parent_id			
from starting s			
join dim_month m			
on s.mon_lastday between m.FiscalYear_StartDate and m.Mon_LastDay			
union			
select			
m.FiscalYear,			
m.mon_year,			
m.Mon_LastDay,			
s.sfdc_ultimate_parent_id			
from new_and_returning s			
join dim_month m			
on s.mon_lastday between m.FiscalYear_StartDate and m.Mon_LastDay			
)			
/*---------------------------------------------------------------------------------------------------------------------------------------*/			
/*---------------------------------------------------------------------------------------------------------------------------------------*/			
,rawdata as (			
select FiscalYear, mon_year,mon_lastday,'Total Active' as record_type,  sfdc_ultimate_parent_id from total_active_data where sfdc_ultimate_parent_id!='00000000-0000-0000-0000-000000000000'			
union all			
select FiscalYear,mon_year,mon_lastday,'Net Active' as record_type, sfdc_ultimate_parent_id from net_active_data where sfdc_ultimate_parent_id!='00000000-0000-0000-0000-000000000000'			
union all			
select FiscalYear,mon_year,mon_lastday,'Contract Active' as record_type,  sfdc_ultimate_parent_id from contract_based_active_data where sfdc_ultimate_parent_id!='00000000-0000-0000-0000-000000000000'			
union all			
select FiscalYear,mon_year,mon_lastday,'Starting' as record_type,  sfdc_ultimate_parent_id from starting where sfdc_ultimate_parent_id!='00000000-0000-0000-0000-000000000000'			
union all			
select FiscalYear,mon_year,mon_lastday, record_type,  sfdc_ultimate_parent_id from new_and_returning where include_flg=True and sfdc_ultimate_parent_id!='00000000-0000-0000-0000-000000000000'			
union all			
select FiscalYear,mon_year,mon_lastday, record_type,  sfdc_ultimate_parent_id from churn where include_flg=True and sfdc_ultimate_parent_id!='00000000-0000-0000-0000-000000000000'			
)	
,BizDevFlg_rawdata as (
select distinct 
mon_year,
sfdc_ultimate_parent_id,
case when bucket_original like '%Biz Dev%' then 'State' else 'District' end BizDevFlg
from {{ ref("vw_fact_revenue_monthly_snapshots") }} 
where record_type='ARR'
and include_flg=true
)
,BizDevFlg_data as (
--BizDev only if both
select 
mon_year,
sfdc_ultimate_parent_id,
max(BizDevFlg) BizDevFlg
from BizDevFlg_rawdata
group by
mon_year,
sfdc_ultimate_parent_id
)		
,data as (
select			
data.FiscalYear,			
data.mon_year,			
data.mon_lastday,
a.account_id,	
data.sfdc_ultimate_parent_id,		
data.record_type	,
isnull(bd.BizDevFlg, 'District') BizDevFlg
from rawdata as	data		
join {{ ref("dim_account") }} a
on data.sfdc_ultimate_parent_id = a.sfdc_account_id
left outer join BizDevFlg_data bd
on bd.mon_year = data.mon_year
and bd.sfdc_ultimate_parent_id = data.sfdc_ultimate_parent_id
)
select
FiscalYear::varchar(20),			
mon_year::integer,			
mon_lastday::date,
account_id::varchar(300),	
sfdc_ultimate_parent_id::varchar(300),		
record_type::varchar(20)	,
BizDevFlg ::varchar(10) ,
'{{ var("loaddate") }}'::timestamp as loaddate
from data
where {{ month_range_to_load() }}