{{ config(
        
        materialized='incremental',
        unique_key='mon_year',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns',
        dist='opportunity_id',
        sort='mon_year'
)
 }}

 with dim_month as --Thread to calculate monthly metrics 
(select 
distinct 
c.mon_year, 
c.mon_firstday, 
c.mon_lastday, 
c.fiscalyear, 
c.fiscalyear_mon, 
c.fiscalyear_startdate, 
c.fiscalyear_enddate 
from {{ source("common","dim_calendar") }} c 
where  {{ month_range_to_load() }}
)
,fiscalyear as (
select
c.fiscalyear current_fiscalyear,
lead(c.fiscalyear) over (order by fiscalyear) next_fisclayear
from (select distinct fiscalyear from {{ source("common","dim_calendar") }}) c
order by fiscalyear)
--actual, not expired every month 
,starting_data as (
--before 202507 FY 25/26 we do not have history
--Starting based on Active Closed-Won opportunities at the end of the last month of the previous fiscal year
select
'ARR-Starting' record_type,
to_char(date_add('day',1,mon.mon_lastday),'yyyymm')::int mon_year,
Last_Day(date_add('day',1,mon.mon_lastday)) mon_lastday,
fy.next_fisclayear fiscalyear,
1 fiscalyear_mon,
fb.opportunity_id,
fb.stage_name,
fb.opp_record_type ,
fb.sfdc_account_id,
fb.sfdc_state_initiative,
fb.sfdc_ultimate_parent_id,
fb.invoiced_date ,
fb.close_date,
fb.start_date,
fb.end_date,
fb.renewal_opportunity_id,
fb.renewal_stage_name,
fb.renewal_invoiced_date,
fb.renewal_close_date,
fb.disable_auto_renewal_opp,
fb.license_unenforced,
fb.bucket Bucket_original,
'Expected' Bucket,
fb.amount,
true include_flg,
case 
when fb.disable_auto_renewal_opp=false and fb.renewal_opportunity_id!='Unknown' then 0 
when fb.disable_auto_renewal_opp=true and fb.renewal_opportunity_id!='Unknown' then 1
else 2 
end audit_id,
false new_opp_this_fy_flg
from {{ ref('stg_revenue') }} fb
join dim_month mon
on
case when fb.license_unenforced  then '3000-01-01'::date else fb.End_Date end >= mon.mon_firstday --still active this month or expires in a future or unenforced, need to start from first day to include not expired this month 
and fb.invoiced_date<=mon.mon_lastday --If it's invoiced AFTER start_date, there is a gap and it will be counted in the invoiced month 
join fiscalyear fy
on fy.current_fiscalyear = mon.fiscalyear
where (fb.renewal_invoiced_date='1900-01-01' or fb.renewal_invoiced_date>mon.mon_lastday)--no invoiced renewals yet in this month
and not(fb.renewal_close_date<=mon.mon_lastday and fb.renewal_stage_name='Closed Lost') --no Closed Lost renewals in this month or before
and mon.fiscalyear_mon = 12 
and mon.mon_year<=202407
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
and (fb.disable_auto_renewal_opp=false or fb.renewal_opportunity_id!='Unknown')
--
union all
--Starting 202505 e.g. FY255/26 we can build Starting based on Active Renewals as they look like at the end of a previous fiscal year
select
'ARR-Starting' record_type,
mon.mon_year,
mon.mon_lastday,
mon.fiscalyear,
mon.fiscalyear_mon,
fo.opportunity_id,
foh.stage_name,
fo.opp_record_type ,
fo.sfdc_account_id,
a.sfdc_state_initiative,
a.sfdc_ultimate_parent_id,
fo.invoiced_date ,
fo.close_date,
fo.start_date,
fo.end_date,
fo.renewal_opportunity_id,
isnull(fro.stage_name,   '{{ var("default_varchar") }}') renewal_stage_name,
isnull(fro.invoiced_date,   '{{ var("default_date") }}') renewal_invoiced_date,
isnull(fro.close_date,   '{{ var("default_date") }}') renewal_close_date,
fo.disable_auto_renewal_opp,
fo.license_unenforced,
case when biz_dev.opportunity_id is not null then 'Expected Biz Dev' else 'Expected' end Bucket_original,
'Expected' Bucket,
case when foh.true_arr=0 then sum(rowo.true_arr) else foh.true_arr end amount,
true include_flg,
case 
when fo.disable_auto_renewal_opp=false and fo.renewal_opportunity_id!='Unknown' then 0 
when fo.disable_auto_renewal_opp=true and fo.renewal_opportunity_id!='Unknown' then 1
else 2 
end audit_id,
false new_opp_this_fy_flg
from {{ ref('fact_opportunity') }}  fo
--
join dim_month mon
on mon.mon_year>=202507 --Starting from FY25/26
and mon.fiscalyear_mon=1
--only direct renewals of won and invoiced opportunities from prev FY
join  {{ ref('fact_opportunity') }} as rowo
on fo.opportunity_id=rowo.renewal_opportunity_id
--How renewals looked like 1 day before the start of the new fiscal year
join {{ ref('fact_opportunity_history') }} foh
on fo.opportunity_id=foh.opportunity_id
--and DATEADD(day, -1, mon.fiscalyear_startdate) between foh.fromdate and foh.todate
--this is more accurate to take into account the change on the last day of a month
--but 2025/2026 FY STarting is much worse with this condition
--let's keep it for future FYs
--example: opportunity 006UZ0000060DrRYAU is counted in 202507 Started but was lost on 20250630
and case when mon_year>202507 then dateadd(minute,24*60-1,DATEADD(day, -1, mon.mon_firstday)) else DATEADD(day, -1, mon.mon_firstday) end between foh.fromdate and foh.todate
--
--account details
join {{ ref('dim_account') }} a
on fo.sfdc_account_id=a.sfdc_account_id
--renewal opportunity details for consistancy with old Starting and other components of ARR
left outer join {{ ref('fact_opportunity') }}  fro
on fo.renewal_opportunity_id=fro.opportunity_id
--
--Biz Dev details
--
left outer join (
select distinct dol.opportunity_id
from {{ ref('dim_opportunity_line') }} dol
where dol.class like '%Biz_Dev%') biz_dev
on fo.opportunity_id = biz_dev.opportunity_id
where
--only direct renewal of invoiced in prev FY Won opportunities
rowo.stage_name ilike '%won%'
and rowo.invoiced_date != '{{ var("default_date") }}'
and rowo.invoiced_Date<mon.fiscalyear_startdate
-- Not Closed, not invoiced (Active) renewals 
and fo.opp_record_type in ('Renewal')
and (
foh.stage_name not in ( 'Closed Won', 'Closed-Won Upsell','Closed Lost')
or
(foh.stage_name = 'Closed Lost' and foh.close_date>=mon.fiscalyear_startdate)
or
(foh.stage_name in ( 'Closed Won', 'Closed-Won Upsell') and (foh.invoiced_date='{{ var("default_date") }}' or  foh.invoiced_date>=mon.fiscalyear_startdate) )
)
--which supposed to be renewed
and (fo.disable_auto_renewal_opp=false or fo.renewal_opportunity_id!='Unknown')
group by
mon.mon_year,
mon.mon_lastday,
mon.fiscalyear,
mon.fiscalyear_mon,
fo.opportunity_id,
foh.stage_name,
fo.opp_record_type ,
fo.sfdc_account_id,
a.sfdc_state_initiative,
a.sfdc_ultimate_parent_id,
fo.invoiced_date ,
fo.close_date,
fo.start_date,
fo.end_date,
fo.renewal_opportunity_id,
isnull(fro.stage_name,   '{{ var("default_varchar") }}'),
isnull(fro.invoiced_date,   '{{ var("default_date") }}'),
isnull(fro.close_date,   '{{ var("default_date") }}'),
fo.disable_auto_renewal_opp,
fo.license_unenforced,
case when biz_dev.opportunity_id is not null then 'Expected Biz Dev' else 'Expected' end,
foh.true_arr
)
select
record_type::varchar(20),
mon_year::integer,
mon_lastday::date,
fiscalyear::varchar(20),
fiscalyear_mon::integer,
opportunity_id::varchar(300),
stage_name::varchar(780),
opp_record_type::varchar(20) ,
sfdc_account_id::varchar(300),
sfdc_state_initiative::boolean,
sfdc_ultimate_parent_id::varchar(300),
invoiced_date::date ,
close_date::date,
start_date::date,
end_date::date,
renewal_opportunity_id::varchar(300),
renewal_stage_name::varchar(780),
renewal_invoiced_date::date,
renewal_close_date::date,
disable_auto_renewal_opp::boolean,
license_unenforced::boolean,
Bucket_original::varchar(765),
Bucket::varchar(765),
amount::float,
include_flg::boolean,
audit_id::integer,
new_opp_this_fy_flg::boolean,
'{{ var("loaddate") }}'::timestamp as loaddate
from starting_data