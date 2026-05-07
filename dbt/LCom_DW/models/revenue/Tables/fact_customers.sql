{{
    config(

        materialized='table',
        dist='account_id',
        sort='mon_year'
        
        )
}}



with dim_month as
(
select FiscalYear, FiscalYear_StartDate, FiscalYear_EndDate, FiscalYear_Mon, Mon_FirstDay, Mon_LastDay,Mon_Year
from {{ ref('dim_month') }}
where mon_year between 201507 and to_char(GetDate(),'yyyymm')
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
,vw_fact_revenue_monthly_snapshots as (
select
f.arr_type,
f.record_type,
f.bucket,
f.mon_year,
f.mon_lastday,
f.fiscalyear,
a.sfdc_ultimate_parent_id,
sum(f.arr_amount) amount
from {{ ref('fact_arr') }} f
join {{ ref('dim_account') }} a
on f.account_id = a.account_id
group by all
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
,active_paying_customers as (
select
arr_type,
mon_year,
mon_lastday,
fiscalyear,
sfdc_ultimate_parent_id,
sum(amount) amount
from vw_fact_revenue_monthly_snapshots
where record_type='ARR'
group by all
having sum(amount)>0
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
,customers_category as (
select
mon_year,
mon_lastday,
fiscalyear,
sfdc_ultimate_parent_id,
max(case when bucket ilike '%biz dev%' then 'State' else 'District' end) BizDevFlg
from vw_fact_revenue_monthly_snapshots
where record_type='ARR'
group by all
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
,contract_based_active_data as (
select
d.mon_year,
d.mon_lastday,
d.fiscalyear,
a.sfdc_ultimate_parent_id
from {{ ref('fact_opportunity') }} o
join {{ ref('dim_account') }} a
on o.account_id = a.account_id
--Won, invoiced opportunities active at in the month
join {{ ref('dim_month') }} d
on d.mon_lastday between o.start_date and o.end_date
where
o.stage_name ilike '%won%'
and o.invoiced_date!='1900-01-01'
and o.invoiced_date <= GetDate()
and d.mon_year <= to_char(GetDate(),'yyyymm')
group by all
having sum(o.amount)>0
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
,Churn as (
select distinct
vfrms.arr_type,
vfrms.mon_year,
vfrms.mon_lastday,
vfrms.fiscalyear,
vfrms.sfdc_ultimate_parent_id,
'Churn' record_type
from
vw_fact_revenue_monthly_snapshots vfrms
--not active customer anymore
left outer join active_paying_customers ah
on ah.sfdc_ultimate_parent_id = vfrms.sfdc_ultimate_parent_id
and vfrms.mon_year = ah.mon_year
and vfrms.arr_type = ah.arr_type
-- 
where vfrms.record_type='ARR-MonthlyReduced'
and vfrms.bucket like '%Cancel%'
and ah.sfdc_ultimate_parent_id is null
group by
all
having max(case when abs(vfrms.amount)>0 then 1 else 0 end) = 1
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
,Expired as (
select distinct
vfrms.arr_type,
vfrms.mon_year,
vfrms.mon_lastday,
vfrms.fiscalyear,
vfrms.sfdc_ultimate_parent_id,
'Expiration' record_type
from
vw_fact_revenue_monthly_snapshots vfrms
--not active customer anymore
left outer join active_paying_customers ah
on ah.sfdc_ultimate_parent_id = vfrms.sfdc_ultimate_parent_id
and vfrms.mon_year = ah.mon_year
and vfrms.arr_type = ah.arr_type
where vfrms.record_type='ARR-MonthlyReduced'
and vfrms.bucket like '%Expir%'
and ah.sfdc_ultimate_parent_id is null
group by
all
having max(case when abs(vfrms.amount)>0 then 1 else 0 end) = 1
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
,Starting as (
select
vfrms.arr_type,
vfrms.mon_year,
vfrms.mon_lastday,
vfrms.fiscalyear,
vfrms.sfdc_ultimate_parent_id,
'Starting' record_type
from
vw_fact_revenue_monthly_snapshots vfrms
where vfrms.record_type='ARR-Starting'
group by
all
having max(case when vfrms.amount>0 then 1 else 0 end) = 1
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
,MonthlyAdded as (
select
vfrms.arr_type,
vfrms.mon_year,
vfrms.mon_lastday,
vfrms.fiscalyear,
vfrms.sfdc_ultimate_parent_id
from
vw_fact_revenue_monthly_snapshots vfrms
where vfrms.record_type='ARR-MonthlyAdded'
group by
all
having max(case when vfrms.amount>0 then 1 else 0 end) = 1
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
,new_and_returning_raw as (
select distinct
vfrms.arr_type,
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
vfrms.amount
from
vw_fact_revenue_monthly_snapshots vfrms
--if included in Starting it is not New or Returning, unless it was Churned after Starting 
left outer join Starting s
on vfrms.sfdc_ultimate_parent_id = s.sfdc_ultimate_parent_id
and vfrms.fiscalyear = s.fiscalyear
and vfrms.arr_type = s.arr_type
-- 
--if included in MonthlyAdded it is not New or Returning, unless it was Churned after MonthlyAdded
left outer join MonthlyAdded ma
on vfrms.sfdc_ultimate_parent_id = ma.sfdc_ultimate_parent_id
and vfrms.fiscalyear = ma.fiscalyear
and vfrms.arr_type = ma.arr_type
and vfrms.mon_year > ma.mon_year
-- 
--Was it Churned or Expired this fiscalyear? 
left outer join
(
select
data.arr_type,
fiscalyear,
sfdc_ultimate_parent_id,
max(mon_lastday) last_churned_mon_lastday
from (select arr_type, fiscalyear, sfdc_ultimate_parent_id, mon_lastday from Churn union all select arr_type, fiscalyear, sfdc_ultimate_parent_id, mon_lastday from Expired) data
group by all
) c
on vfrms.sfdc_ultimate_parent_id = c.sfdc_ultimate_parent_id
and vfrms.fiscalyear = c.fiscalyear
and vfrms.arr_type = c.arr_type
--
--Was it present in ARR previous fiscal years?
left outer join
(
select
arr_type,
fiscalyear,
sfdc_ultimate_parent_id,
max(mon_lastday) last_present_mon_lastday
from vw_fact_revenue_monthly_snapshots
where record_type='ARR'
group by
all
) prev_fy
on vfrms.sfdc_ultimate_parent_id = prev_fy.sfdc_ultimate_parent_id
and vfrms.fiscalyear != prev_fy.fiscalyear
and vfrms.mon_lastday > prev_fy.last_present_mon_lastday
and vfrms.arr_type = prev_fy.arr_type
--
-- 
where vfrms.record_type='ARR-MonthlyAdded'
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
arr_type,
FiscalYear,
mon_year,
mon_lastday,
record_type,
sfdc_ultimate_parent_id
from new_and_returning_raw
group by
all
having max(case when amount>0 then 1 else 0 end) = 1
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
, net_active_data as (
select
s.arr_type,
m.FiscalYear,
m.mon_year,
m.Mon_LastDay,
s.sfdc_ultimate_parent_id
from starting s
join dim_month m
on s.mon_lastday between m.FiscalYear_StartDate and m.Mon_LastDay
union
select
s.arr_type,
m.FiscalYear,
m.mon_year,
m.Mon_LastDay,
s.sfdc_ultimate_parent_id
from new_and_returning s
join dim_month m
on s.mon_lastday between m.FiscalYear_StartDate and m.Mon_LastDay
except
select
s.arr_type,
m.FiscalYear,
m.Mon_Year,
m.Mon_LastDay,
s.sfdc_ultimate_parent_id
from (select arr_type, fiscalyear, Mon_Year, sfdc_ultimate_parent_id, mon_lastday from Churn union all select arr_type, fiscalyear, Mon_Year, sfdc_ultimate_parent_id, mon_lastday from Expired) s
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
)
/*---------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------------------------------*/
,total_active_data as (
select
s.arr_type,
m.FiscalYear,
m.mon_year,
m.Mon_LastDay,
s.sfdc_ultimate_parent_id
from starting s
join dim_month m
on s.mon_lastday between m.FiscalYear_StartDate and m.Mon_LastDay
union
select
s.arr_type,
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
select arr_type, FiscalYear, mon_year,mon_lastday,'Total Active' as record_type,  sfdc_ultimate_parent_id from total_active_data where sfdc_ultimate_parent_id!='00000000-0000-0000-0000-000000000000'
union all
select arr_type, FiscalYear,mon_year,mon_lastday,'Net Active' as record_type, sfdc_ultimate_parent_id from net_active_data where sfdc_ultimate_parent_id!='00000000-0000-0000-0000-000000000000'
union all
select 'Preliminary' arr_type, FiscalYear,mon_year,mon_lastday,'Contract Active' as record_type,  sfdc_ultimate_parent_id from contract_based_active_data where sfdc_ultimate_parent_id!='00000000-0000-0000-0000-000000000000'
union all
select 'Backdated' arr_type, FiscalYear,mon_year,mon_lastday,'Contract Active' as record_type,  sfdc_ultimate_parent_id from contract_based_active_data where sfdc_ultimate_parent_id!='00000000-0000-0000-0000-000000000000'
union all
select 'True' arr_type, FiscalYear,mon_year,mon_lastday,'Contract Active' as record_type,  sfdc_ultimate_parent_id from contract_based_active_data where sfdc_ultimate_parent_id!='00000000-0000-0000-0000-000000000000'
union all
select arr_type, FiscalYear,mon_year,mon_lastday,'Starting' as record_type,  sfdc_ultimate_parent_id from starting where sfdc_ultimate_parent_id!='00000000-0000-0000-0000-000000000000'
union all
select arr_type, FiscalYear,mon_year,mon_lastday, record_type,  sfdc_ultimate_parent_id from new_and_returning where sfdc_ultimate_parent_id!='00000000-0000-0000-0000-000000000000'
union all
select arr_type, FiscalYear,mon_year,mon_lastday, record_type,  sfdc_ultimate_parent_id from churn where sfdc_ultimate_parent_id!='00000000-0000-0000-0000-000000000000'
union all
select arr_type, FiscalYear,mon_year,mon_lastday, record_type,  sfdc_ultimate_parent_id from expired where sfdc_ultimate_parent_id!='00000000-0000-0000-0000-000000000000'
)
,data as (
select
data.arr_type,
data.FiscalYear,
data.mon_year,
data.mon_lastday,
a.account_id,
data.sfdc_ultimate_parent_id,
data.record_type,
isnull(bd.BizDevFlg, 'District') BizDevFlg
from rawdata as data
join dw.common.dim_account a
on data.sfdc_ultimate_parent_id = a.sfdc_account_id
left outer join customers_category bd
on bd.mon_year = data.mon_year
and bd.sfdc_ultimate_parent_id = data.sfdc_ultimate_parent_id
)
select
arr_type::varchar(20),
FiscalYear::varchar(20),
mon_year::integer,
mon_lastday::date,
account_id::varchar(300),
sfdc_ultimate_parent_id::varchar(300),
record_type::varchar(20),
BizDevFlg ::varchar(10) ,
'{{ var("loaddate") }}'::timestamp as loaddate
from data

 



