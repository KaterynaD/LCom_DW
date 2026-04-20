{{
    config(

        materialized='table',        
        dist='opportunity_id' 
        
        )
}}

with
--1. starting 
--Won, invoiced opportunities active on 1st day 1st fiscal month 
starting_data as (
select
ARR_Type,
'ARR-Starting'::varchar(20) record_type,
m.mon_year,
m.mon_lastday,
m.fiscalyear,
m.fiscalyear_mon,
fb.HasParent,
fb.opportunity_id,
fb.stage_name,
fb.account_id,
fb.invoiced_date,
fb.close_date,
fb.start_date,
fb.start_date_sfdc,
fb.end_date,
fb.end_date_sfdc,
fb.invoiced_date arr_activation_date,
'3000-01-01'::date arr_deactivation_date,
fb.renewal_opportunity_id,
fb.renewal_stage_name,
fb.renewal_invoiced_date,
fb.renewal_close_date,
fb.renewal_start_date,
fb.renewal_start_date_sfdc,
fb.renewal_end_date,
fb.sfdc_product_id,
'Sales : Starting : ' +case when fb.bucket ilike '%biz_dev%' then 'Biz Dev' else 'ARR' end as Bucket,
fb.Bucket as Bucket_SFDC,
fb.total_price ,
fb.parent_total_price,
fb.max_parent_end_date,
fb.max_parent_end_date_sfdc
from {{ ref("int_arr_base") }} fb
--Won, invoiced opportunities active on 1st day 1st fiscal month 
join {{ ref("dim_month") }} m
on
m.fiscalyear_mon = 1 and
dateadd(day,-1,m.mon_firstday) between fb.start_date and fb.end_date
where
--Won, invoiced opportunities 
fb.stage_name ilike '%won%'
and fb.invoiced_date!='1900-01-01'
and fb.bucket in (
'Sales : New Business : ARR',
'Sales : New Business : Biz Dev',
'Sales : Renewal : ARR',
'Sales : Renewal : Biz Dev',
'Sales : Upsell : ARR',
'Sales : Upsell : Biz Dev',
'Sales : Reseller ARR Renewal',
'Sales : Reseller ARR Upsell'
) 
)
-- 
-- 
--2. positive - added each month 
--2.1 no parent opportunity 
-- 
-- 
,add_monthly_new as (
select
ARR_Type,
'ARR-MonthlyAdded'::varchar(20) record_type,
fb.mon_year,
fb.mon_lastday,
fb.fiscalyear,
fb.fiscalyear_mon,
fb.HasParent,
fb.opportunity_id,
fb.stage_name,
fb.account_id,
fb.invoiced_date,
fb.close_date,
fb.start_date,
fb.start_date_sfdc,
fb.end_date,
fb.end_date_sfdc,
fb.arr_activation_date,
'3000-01-01'::date arr_deactivation_date,
fb.renewal_opportunity_id,
fb.renewal_stage_name,
fb.renewal_invoiced_date,
fb.renewal_close_date,
fb.renewal_start_date,
fb.renewal_start_date_sfdc,
fb.renewal_end_date,
fb.sfdc_product_id,
fb.Bucket,
fb.Bucket as Bucket_SFDC,
fb.total_price ,
fb.parent_total_price,
fb.max_parent_end_date,
fb.max_parent_end_date_sfdc
from {{ ref("int_arr_base") }} fb
where fb.HasParent = False -- first in a chain, no P.I or Downsell expected 
--Won, invoiced opportunities 
and fb.stage_name ilike '%won%'
and fb.invoiced_date!='1900-01-01'
and fb.bucket in (
'Sales : New Business : ARR',
'Sales : New Business : Biz Dev',
'Sales : Renewal : ARR',
'Sales : Renewal : Biz Dev',
'Sales : Reseller ARR Renewal'
)
)
-- 
--2.2 Upsell - can be separate opportunity without a parent or a part of renewal with parent 
-- 
,add_monthly_upsell as (
select
ARR_Type,
'ARR-MonthlyAdded'::varchar(20) record_type,
fb.mon_year,
fb.mon_lastday,
fb.fiscalyear,
fb.fiscalyear_mon,
fb.HasParent,
fb.opportunity_id,
fb.stage_name,
fb.account_id,
fb.invoiced_date,
fb.close_date,
fb.start_date,
fb.start_date_sfdc,
fb.end_date,
fb.end_date_sfdc,
fb.arr_activation_date,
'3000-01-01'::date arr_deactivation_date,
fb.renewal_opportunity_id,
fb.renewal_stage_name,
fb.renewal_invoiced_date,
fb.renewal_close_date,
fb.renewal_start_date,
fb.renewal_start_date_sfdc,
fb.renewal_end_date,
fb.sfdc_product_id,
fb.Bucket,
fb.Bucket as Bucket_SFDC,
fb.total_price ,
fb.parent_total_price,
fb.max_parent_end_date,
fb.max_parent_end_date_sfdc
from {{ ref("int_arr_base") }} fb
where --Won, invoiced opportunities 
fb.stage_name ilike '%won%'
and fb.invoiced_date!='1900-01-01'
and fb.bucket in (
'Sales : Upsell : ARR',
'Sales : Upsell : Biz Dev',
'Sales : Reseller ARR Upsell'
)
)
-- 
--2.3 There is a parent opportunity 
-- But it ended 2 or more days before renewal started 
-- 
,add_monthly_like_new as (
select 
ARR_Type,
'ARR-MonthlyAdded'::varchar(20) record_type,
fb.mon_year,
fb.mon_lastday,
fb.fiscalyear,
fb.fiscalyear_mon,
fb.HasParent,
fb.opportunity_id,
fb.stage_name,
fb.account_id,
fb.invoiced_date,
fb.close_date,
fb.start_date,
fb.start_date_sfdc,
fb.end_date,
fb.end_date_sfdc,
fb.arr_activation_date,
'3000-01-01'::date arr_deactivation_date,
fb.renewal_opportunity_id,
fb.renewal_stage_name,
fb.renewal_invoiced_date,
fb.renewal_close_date,
fb.renewal_start_date,
fb.renewal_start_date_sfdc,
fb.renewal_end_date,
fb.sfdc_product_id,
fb.Bucket,
fb.Bucket as Bucket_SFDC,
fb.total_price ,
fb.parent_total_price,
fb.max_parent_end_date,
fb.max_parent_end_date_sfdc
from {{ ref("int_arr_base") }} fb
where
DATEDIFF(day, fb.max_parent_end_date, fb.start_date) > 1
and fb.HasParent = True --has parents 
--Won, invoiced opportunities 
and fb.stage_name ilike '%won%'
and fb.invoiced_date!='1900-01-01'
and fb.bucket in (
'Sales : New Business : ARR',
'Sales : New Business : Biz Dev',
'Sales : Renewal : ARR',
'Sales : Renewal : Biz Dev',
'Sales : Reseller ARR Renewal'
)
)
-- 
--2.4 There is a parent opportunity 
-- But it ended the day before this renewal started or before 
-- 
,add_monthly_placeholder_for_PI_or_downsell as (
select
ARR_Type,
'ARR-MonthlyAdded'::varchar(20) record_type,
fb.mon_year,
fb.mon_lastday,
fb.fiscalyear,
fb.fiscalyear_mon,
fb.HasParent,
fb.opportunity_id,
fb.stage_name,
fb.account_id,
fb.invoiced_date,
fb.close_date,
fb.start_date,
fb.start_date_sfdc,
fb.end_date,
fb.end_date_sfdc,
fb.arr_activation_date,
'3000-01-01'::date arr_deactivation_date,
fb.renewal_opportunity_id,
fb.renewal_stage_name,
fb.renewal_invoiced_date,
fb.renewal_close_date,
fb.renewal_start_date,
fb.renewal_start_date_sfdc,
fb.renewal_end_date,
fb.sfdc_product_id,
fb.Bucket,
fb.Bucket as Bucket_SFDC,
fb.total_price ,
fb.parent_total_price,
fb.max_parent_end_date,
fb.max_parent_end_date_sfdc
from {{ ref("int_arr_base") }} fb
where
DATEDIFF(day, fb.max_parent_end_date, fb.start_date) <= 1
and fb.HasParent = True --has parent 
--Won, invoiced BEFORE or exactly on Parent End Date opportunities 
and fb.stage_name ilike '%won%'
and fb.invoiced_date!='1900-01-01'
and fb.bucket in (
'Sales : Placeholder for Price Increase or Downsell : ARR',
'Sales : Placeholder for Price Increase or Downsell : Biz Dev'
)
)
-- 
--==Final 2 - added monthly 
-- 
,add_monthly as (
select * from add_monthly_new
union all
select * from add_monthly_upsell
union all
select * from add_monthly_like_new
union all
select * from add_monthly_placeholder_for_PI_or_downsell
)
-- 
-- 
--3. negative - removed each month 
-- 
-- 3.1 Expired 
-- because we add opportunities without renewals 
-- or renewal can be invoiced or cancelled later then 
-- opportunity end date 
-- 
,expired_monthly_added as (
select distinct
ARR_Type,
'ARR-MonthlyReduced'::varchar(20) record_type,
m.mon_year,
m.mon_lastday,
m.fiscalyear,
m.fiscalyear_mon,
fb.HasParent,
fb.opportunity_id,
fb.stage_name,
fb.account_id,
fb.invoiced_date,
fb.close_date,
fb.end_date start_date,
fb.start_date_sfdc,

case
   when DATEDIFF(day, fb.end_date, fb.renewal_start_date) > 1 then '3000-01-01'::date
   when fb.renewal_stage_name in ( 'Closed Won', 'Closed-Won Upsell') and fb.renewal_invoiced_date!='1900-01-01' then dateadd(day, -1,fb.renewal_invoiced_date)
   when fb.renewal_stage_name in ( 'Closed Lost') then dateadd(day, -1,fb.renewal_close_date)
   else '3000-01-01'::date
end as end_date,

fb.end_date_sfdc,

fb.end_date as arr_activation_date,
case
   when DATEDIFF(day, fb.end_date, fb.renewal_start_date) > 1 then '3000-01-01'::date
   when fb.renewal_stage_name in ( 'Closed Won', 'Closed-Won Upsell') and fb.renewal_invoiced_date!='1900-01-01' then dateadd(day, -1,fb.renewal_invoiced_date)
   when fb.renewal_stage_name in ( 'Closed Lost') then dateadd(day, -1,fb.renewal_close_date)
   else '3000-01-01'::date
end  as arr_deactivation_date,

fb.renewal_opportunity_id,
fb.renewal_stage_name,
fb.renewal_invoiced_date,
fb.renewal_close_date,
fb.renewal_start_date,
fb.renewal_start_date_sfdc,
fb.renewal_end_date,
fb.sfdc_product_id,
'Sales : Expired: ' +case when fb.bucket ilike '%biz_dev%' then 'Biz Dev' else 'ARR' end as Bucket,
fb.Bucket as Bucket_SFDC,
fb.total_price ,
0 parent_total_price,
fb.max_parent_end_date,
fb.max_parent_end_date_sfdc
from add_monthly as fb
--in the month of the opportunity End Date only in FY year when it was added
join {{ ref("dim_month") }} m
on dateadd(day,1,fb.end_date) between m.mon_firstday and m.mon_lastday
and m.fiscalyear = fb.fiscalyear
where fb.total_price != 0
--renewal (won or lost) with a gap or not "ready" (not invoiced or Close Lost Close)
and (DATEDIFF(day, fb.end_date, fb.renewal_start_date) > 1 or not((fb.renewal_stage_name in ( 'Closed Won', 'Closed-Won Upsell') and fb.renewal_invoiced_date!='1900-01-01') or (fb.renewal_stage_name in ( 'Closed Lost')) ))
)
,expired_starting_data as (
select distinct
ARR_Type,
'ARR-MonthlyReduced'::varchar(20) record_type,
/*if a starting opportunity expired - we add expiration next month after expiration - 1st month when starting was added*/
m.mon_year,
m.mon_lastday,
m.fiscalyear,
m.fiscalyear_mon,
fb.HasParent,
fb.opportunity_id,
fb.stage_name,
fb.account_id,
fb.invoiced_date,
fb.close_date,
fb.end_date start_date,
fb.start_date_sfdc,
case
   when DATEDIFF(day, fb.end_date, fb.renewal_start_date) > 1 then '3000-01-01'::date
   when fb.renewal_stage_name in ( 'Closed Won', 'Closed-Won Upsell') and fb.renewal_invoiced_date!='1900-01-01' then dateadd(day, -1,fb.renewal_invoiced_date)
   when fb.renewal_stage_name in ( 'Closed Lost') then dateadd(day, -1,fb.renewal_close_date)
   else '3000-01-01'::date
end as end_date,
fb.end_date_sfdc,
fb.end_date as arr_activation_date,
case
   when DATEDIFF(day, fb.end_date, fb.renewal_start_date) > 1 then '3000-01-01'::date
   when fb.renewal_stage_name in ( 'Closed Won', 'Closed-Won Upsell') and fb.renewal_invoiced_date!='1900-01-01' then dateadd(day, -1,fb.renewal_invoiced_date)
   when fb.renewal_stage_name in ( 'Closed Lost') then dateadd(day, -1,fb.renewal_close_date)
   else '3000-01-01'::date
end as arr_deactivation_date,
fb.renewal_opportunity_id,
fb.renewal_stage_name,
fb.renewal_invoiced_date,
fb.renewal_close_date,
fb.renewal_start_date,
fb.renewal_start_date_sfdc,
fb.renewal_end_date,
fb.sfdc_product_id,
'Sales : Expired: ' +case when fb.bucket ilike '%biz_dev%' then 'Biz Dev' else 'ARR' end as Bucket,
fb.Bucket_SFDC,
fb.total_price ,
fb.parent_total_price,
fb.max_parent_end_date,
fb.max_parent_end_date_sfdc
from starting_data as fb
--in the month of the opportunity End Date only in FY year when it was added as Starting
--or on the last day of a previous FY
join {{ ref("dim_month") }} m
on dateadd(day,1,fb.end_date) between m.mon_firstday and m.mon_lastday
and (m.fiscalyear = fb.fiscalyear or m.fiscalyear_mon=12)
where  fb.total_price != 0
)
-- 
-- 3.1 Cancellation 
-- 
,cancellation_monthly as (
select distinct
ARR_Type,
'ARR-MonthlyReduced'::varchar(20) record_type,
fb.mon_year,
fb.mon_lastday,
fb.fiscalyear,
fb.fiscalyear_mon,
fb.HasParent,
fb.opportunity_id,
fb.stage_name,
fb.account_id,
fb.invoiced_date,
fb.close_date,
fb.start_date,
fb.start_date_sfdc,
fb.end_date,
fb.end_date_sfdc,
fb.arr_activation_date,
'3000-01-01'::date arr_deactivation_date,
fb.renewal_opportunity_id,
fb.renewal_stage_name,
fb.renewal_invoiced_date,
fb.renewal_close_date,
fb.renewal_start_date,
fb.renewal_start_date_sfdc,
fb.renewal_end_date,
fb.sfdc_product_id,
fb.Bucket,
fb.Bucket as Bucket_SFDC,
fb.total_price ,
fb.parent_total_price,
fb.max_parent_end_date,
fb.max_parent_end_date_sfdc
from {{ ref("int_arr_base") }} fb
--parent opportunity ended in the same fiscal year as cancellation or in starting which may ends on or later then 06/30 
--FY Parent End Date
join {{ ref("dim_month") }} mpe
on fb.max_parent_end_date between mpe.mon_firstday and mpe.mon_lastday
--FY Parent End date is end of previous FY
join {{ ref("dim_month") }} mpe_extended
on DATEADD(day,1,fb.max_parent_end_date) between mpe_extended.mon_firstday and mpe_extended.mon_lastday
where
(fb.fiscalyear = mpe.fiscalyear or fb.fiscalyear = mpe_extended.fiscalyear )
and
DATEDIFF(day, fb.max_parent_end_date, fb.start_date) <= 1 --there is no gap between parent end date and cancel start date, otherwise, there is only expiration 
and 
fb.HasParent = True --has parent 
--Closed Lost 
and fb.stage_name = 'Closed Lost'
and fb.bucket in (
'Sales : Cancellation : ARR',
'Sales : Cancellation : Biz Dev'
)
)
-- 
,all_data as (
select * from starting_data
union all
select * from add_monthly
union all
select * from expired_monthly_added
union all
select * from expired_starting_data
union all
select * from cancellation_monthly
)
select
ARR_Type::varchar(20),
record_type::varchar(20),
mon_year::integer,
mon_lastday::date,
fiscalyear::varchar(20),
fiscalyear_mon::integer,
HasParent::boolean,
opportunity_id::varchar(300),
stage_name::varchar(780),
account_id,
invoiced_date::date ,
close_date::date,
start_date::date,
start_date_sfdc::date,
end_date::date,
end_date_sfdc::date,
arr_activation_date::date,
arr_deactivation_date::date,
renewal_opportunity_id::varchar(300),
renewal_stage_name::varchar(780),
renewal_invoiced_date::date,
renewal_close_date::date,
renewal_start_date::date,
renewal_start_date_sfdc::date,
renewal_end_date::date,
sfdc_product_id::varchar(300) ,
replace(replace(Bucket, 'Sales : ',''),' : ',': ')::varchar(100) as bucket,
bucket_sfdc::varchar(100),
total_price::numeric(38,10) as total_price ,
parent_total_price::numeric(38,10) as parent_total_price,
max_parent_end_date::date,
max_parent_end_date_sfdc::date,
'{{ var("loaddate") }}'::timestamp as loaddate
from all_data
where mon_year<=TO_CHAR(GETDATE(), 'YYYYMM')::int