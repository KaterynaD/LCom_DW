{{
    config(

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
where mon_year<=TO_CHAR(GETDATE(), 'YYYYMM')::int
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
case when fb.renewal_opportunity_id!='Unknown' then 0 else 1 end audit_id,
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
fo.stage_name,
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
'Expected' Bucket_original,
'Expected' Bucket,
case when foh.true_arr=0 then sum(rowo.true_arr) else foh.true_arr end amount,
true include_flg,
case when fo.renewal_opportunity_id!='Unknown' then 0 else 1 end audit_id,
false new_opp_this_fy_flg
from {{ ref('fact_opportunity') }}  fo
--
join dim_month mon
on mon.mon_year>=202507 --Starting from FY25/26
and mon.fiscalyear_mon=1
--only direct renewals of won and invoiced opportunities from prev FY
join 
   (
select
p.renewal_opportunity_id, p.invoiced_Date, p.true_arr
from {{ ref('fact_opportunity') }} p
where p.stage_name ilike '%won%'
and p.invoiced_date != '1900-01-01'
) as rowo
on fo.opportunity_id=rowo.renewal_opportunity_id
--How renewals looked like 2 months before the start of the fiscal year
--2 month is selected because most renewals are started 1-2 months before the start of the fiscal/school year
join {{ ref('fact_opportunity_history') }} foh
on fo.opportunity_id=foh.opportunity_id
and DATEADD(month, -2, mon.fiscalyear_startdate) between foh.fromdate and foh.todate
--
--account details
join {{ ref('dim_account') }} a
on fo.sfdc_account_id=a.sfdc_account_id
--renewal opportunity details for consistancy with old Starting and other components of ARR
left outer join {{ ref('fact_opportunity') }}  fro
on fo.renewal_opportunity_id=fro.opportunity_id
--
where
--not closed yet renewal opportunities (rowo: with won and invoiced opportunities before the start of the fiscal year)
rowo.invoiced_Date<mon.fiscalyear_startdate
and fo.opp_record_type in ('Renewal')
and foh.stage_name not in ( 'Closed Won', 'Closed-Won Upsell','Closed Lost')
and foh.invoiced_date='1900-01-01'
--which supposed to be renewed
and (fo.disable_auto_renewal_opp=false or fo.renewal_opportunity_id!='Unknown')
and fo.close_date >= DATEADD(month, -2, mon.fiscalyear_startdate)
group by
mon.mon_year,
mon.mon_lastday,
mon.fiscalyear,
mon.fiscalyear_mon,
fo.opportunity_id,
fo.stage_name,
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
foh.true_arr
)
--
--==
--positive - added each month
,expected_add_monthly_new as (
select distinct
'ARR-MonthlyAdded' record_type,
fb.mon_year,
fb.mon_lastday,
fb.fiscalyear,
fb.fiscalyear_mon,
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
fb.Bucket,
fb.amount,
true include_flg,
case when fb.renewal_opportunity_id!='Unknown' then 0 else 1 end audit_id,
true new_opp_this_fy_flg
from {{ ref('stg_revenue') }} fb
join dim_month m on m.mon_year = fb.mon_year
where
fb.bucket in (
'Sales : New Business : ARR',
'Sales : New Business : Biz Dev'
)
and (fb.disable_auto_renewal_opp=false or fb.renewal_opportunity_id!='Unknown')
and not(fb.renewal_close_date<=m.mon_lastday and fb.renewal_stage_name='Closed Lost') --no Closed Lost renewals in this month or before
)
--
--
,expected_add_monthly_upsell as (
select distinct
'ARR-MonthlyAdded' record_type,
fb.mon_year,
fb.mon_lastday,
fb.fiscalyear,
fb.fiscalyear_mon,
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
fb.Bucket,
fb.amount,
true include_flg,
case when fb.renewal_opportunity_id!='Unknown' then 0 else 1 end audit_id,
true new_opp_this_fy_flg
from {{ ref('stg_revenue') }} fb
join dim_month m on m.mon_year = fb.mon_year
where
fb.bucket in (
'Sales : Upsell : ARR',
'Sales : Upsell : Biz Dev',
'Sales : Reseller ARR Upsell'
)
and (fb.disable_auto_renewal_opp=false or fb.renewal_opportunity_id!='Unknown')
and not(fb.renewal_close_date<=m.mon_lastday and fb.renewal_stage_name='Closed Lost') --no Closed Lost renewals in this month or before
)
--==
--Like New: if there is a renewal of an opportunity NOT included in Starting/New because there is a gap in payments, e.g. Month of Invoice Date > Month of Start Date or renewal in years after previous active opportunity
--or multi-year renewal when previous started/invoiced years ago
--However broken chain of renewals can add duplicates:if renewal opp id is not added to renewal_opportunity_id
,raw_expected_add_monthly_like_new as (
select distinct
'ARR-MonthlyAdded' record_type,
fb.mon_year,
fb.mon_lastday,
fb.fiscalyear,
fb.fiscalyear_mon,
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
fb.Bucket,
fb.amount,
case when sd.opportunity_id is not null or ad.opportunity_id is not null or ud.opportunity_id is not null then false else true end include_flg,
case when fb.renewal_opportunity_id!='Unknown' then 0 else 1 end audit_id,
case when ad.opportunity_id is not null  then true else false end new_opp_this_fy_flg
from {{ ref('stg_revenue') }} fb
join dim_month m on m.mon_year = fb.mon_year
join {{ ref('stg_opportunities_chain_of_renewals') }} ocr
on fb.opportunity_id=ocr.opportunity_id
--Need to check the opportunity or it's parent renewals was NOT included in Starting 
left outer join starting_data sd
on ocr.parent_opportunities like '%'+ sd.opportunity_id+'%'
and sd.fiscalyear_mon=1
and sd.fiscalyear=fb.fiscalyear
and sd.include_flg=true
--Need to check the opportunity or it's parent renewals was NOT included in New as New
left outer join expected_add_monthly_new ad
on ocr.parent_opportunities like '%'+ ad.opportunity_id+'%'
and fb.fiscalyear=ad.fiscalyear
and fb.fiscalyear_mon>=ad.fiscalyear_mon --renewal opportunity can be crenewed even in the same month as new added
and ad.include_flg=True
--Need to check the opportunit's parent is not included as Upsell
--If the opportunity is Upsell + Renewal in one then having Upsell and Renewal is Ok
left outer join expected_add_monthly_upsell ud
on ocr.parent_opportunities like '%'+ ud.opportunity_id+'%'
and fb.opportunity_id != ud.opportunity_id --separate Upsell in a parent, not included in this opportunity
and fb.fiscalyear=ud.fiscalyear
and fb.fiscalyear_mon>=ud.fiscalyear_mon --renewal opportunity can be renewed even in the same month as new added
and ud.include_flg=True
where fb.bucket in (
'Sales : Renewal : ARR',
'Sales : Renewal : Biz Dev',
'Sales : Reseller ARR Renewal'
)
and (fb.disable_auto_renewal_opp=false or fb.renewal_opportunity_id!='Unknown')
and not(fb.renewal_close_date<=m.mon_lastday and fb.renewal_stage_name='Closed Lost') --no Closed Lost renewals in this month or before
)
,expected_add_monthly_like_new as (
select distinct
'ARR-MonthlyAdded' record_type,
fb.mon_year,
fb.mon_lastday,
fb.fiscalyear,
fb.fiscalyear_mon,
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
fb.Bucket,
fb.amount,
case when ad.opportunity_id is not null   then false else fb.include_flg end include_flg,
fb.audit_id,
fb.new_opp_this_fy_flg
from raw_expected_add_monthly_like_new fb
join dim_month m on m.mon_year = fb.mon_year
join {{ ref('stg_opportunities_chain_of_renewals') }} ocr
on fb.opportunity_id=ocr.opportunity_id
--Check if the opportunity included in Starting is done in raw_expected_add_monthly_like_new
--Check if the opportunity included in New/Upsell is done in raw_expected_add_monthly_like_new
--Now we need to check if the parent or grand parent opportunity was included in other Renewals (raw_expected_add_monthly_like_new)
left outer join raw_expected_add_monthly_like_new ad
on ocr.parent_opportunities like '%'+ ad.opportunity_id+'%' --parents
and ad.opportunity_id!=fb.opportunity_id --but not itself
and fb.fiscalyear=ad.fiscalyear
and fb.fiscalyear_mon>=ad.fiscalyear_mon --renewal opportunity can be renewed even in the same month as new added
and ad.include_flg=True
)
--
--==
--renewal was expected (in Starting), so only Price Increase including
,expected_add_monthly_price_increase as (
select distinct
'ARR-MonthlyAdded' record_type,
fb.mon_year,
fb.mon_lastday,
fb.fiscalyear,
fb.fiscalyear_mon,
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
fb.bucket,
fb.amount,
case when ad.opportunity_id is null then true else false end include_flg,
case when fb.renewal_opportunity_id!='Unknown' then 0 else 1 end audit_id,
case when nad.opportunity_id is not null  then true else false end new_opp_this_fy_flg
from {{ ref('stg_revenue') }} fb
join dim_month m on m.mon_year = fb.mon_year
join {{ ref('stg_opportunities_chain_of_renewals') }} ocr
on fb.opportunity_id=ocr.opportunity_id
--Price Increase already included in Renewals If we added renewals (like "New) - no need in Price Increase
--In all other cases PI is added without specially added restrictions:
--1.New short-term contract and a chain of a few renewals with PI
--2.12-months or longer contract renewals if they are in Starting but not expected_add_monthly_like_new
left outer join expected_add_monthly_like_new ad
on fb.opportunity_id=ad.opportunity_id
and fb.fiscalyear=ad.fiscalyear
and fb.fiscalyear_mon=ad.fiscalyear_mon
and ad.include_flg=true
--check if a parent or grand parent opportunity was new
left outer join expected_add_monthly_new nad
on ocr.parent_opportunities like '%'+ nad.opportunity_id+'%'
and fb.fiscalyear=nad.fiscalyear
and fb.fiscalyear_mon>=nad.fiscalyear_mon --renewal opportunity can be crenewed even in the same month as new added
and nad.include_flg=True
--No need if a parent was Upsell, we add Price Increase based on full renewal amount added or not (ad)
--
where
fb.bucket in (
'Sales : Price Increased : ARR',
'Sales : Price Increased : Biz Dev'
)
and (fb.disable_auto_renewal_opp=false or fb.renewal_opportunity_id!='Unknown')
)
--
--==
--
,expected_add_monthly as (
select * from expected_add_monthly_new
union all
select * from expected_add_monthly_upsell
union all
select * from expected_add_monthly_like_new
union all
select * from expected_add_monthly_price_increase
)
--
--negative - minus every month
,expected_reduced_monthly_cancellation as (
select distinct
'ARR-MonthlyReduced' record_type,
fb.mon_year,
fb.mon_lastday,
fb.fiscalyear,
fb.fiscalyear_mon,
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
fb.bucket,
fb.amount,
case when sd.opportunity_id is not null or ad.opportunity_id is not null then true else false end include_flg,
0 audit_id,
case when ad.opportunity_id is not null and ad.bucket in ('Sales : New Business : ARR','Sales : New Business : Biz Dev') then true else false end new_opp_this_fy_flg
from {{ ref('stg_revenue') }} fb
join dim_month m on m.mon_year = fb.mon_year
join {{ ref('stg_opportunities_chain_of_renewals') }} ocr
on fb.opportunity_id=ocr.opportunity_id
--cancelled amount was expected in non expired opportunities in the last month of a previous fiscal year (starting)
--it's possible Starting Opportunity is NOT a direct parent of the cancelled opportunity, but grand or garnd-grand father
--Need to compare Starting Opp Id to to ALL cancelled opportunity parents
left outer join starting_data sd
on ocr.parent_opportunities like '%'+ sd.opportunity_id+'%'
and sd.fiscalyear_mon=1
and sd.fiscalyear=fb.fiscalyear
and sd.include_flg=True
--cancelled amount was expected in this or any previous fiscal year month in this fiscal year
--it's possible Newly added Opportunity is NOT a direct parent of the cancelled opportunity, but grand or garnd-grand father
--Need to compare New/Upsell/Renewal like New added Opp Id to to ALL cancelled opportunity parents 
left outer join expected_add_monthly ad
on ocr.parent_opportunities like '%'+ ad.opportunity_id+'%'
and fb.fiscalyear=ad.fiscalyear
and fb.fiscalyear_mon>=ad.fiscalyear_mon --renewal opportunity can be cancelled/closed even in the same month as new added
and ad.include_flg=True
where
fb.bucket in (
'Sales : Cancellation : ARR',
'Sales : Cancellation : Biz Dev'
)
)
--reduction as like price increase
,expected_reduced_monthly_reduction as (
select distinct
'ARR-MonthlyReduced' record_type,
fb.mon_year,
fb.mon_lastday,
fb.fiscalyear,
fb.fiscalyear_mon,
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
fb.bucket,
fb.amount,
case when ad.opportunity_id is null then true else false end include_flg,
0 audit_id,
case when nad.opportunity_id is not null  then true else false end new_opp_this_fy_flg
from {{ ref('stg_revenue') }} fb
join dim_month m on m.mon_year = fb.mon_year
join {{ ref('stg_opportunities_chain_of_renewals') }} ocr
on fb.opportunity_id=ocr.opportunity_id
--should be included in all cases except if it's a renewal added "like new". Reduced amount is already included
--In all other cases Reduced amount is added without specially added restrictions:
--1.New short-term contract and a chain of a few renewals with PI
--2.12-months or longer contract renewals if they are in Starting but not expected_add_monthly_like_new
left outer join expected_add_monthly_like_new ad
on fb.opportunity_id=ad.opportunity_id
and fb.fiscalyear=ad.fiscalyear
and fb.fiscalyear_mon=ad.fiscalyear_mon
and ad.include_flg=true
--check if a parent or grand parent opportunity was new
left outer join expected_add_monthly_new nad
on ocr.parent_opportunities like '%'+ nad.opportunity_id+'%'
and fb.fiscalyear=nad.fiscalyear
and fb.fiscalyear_mon>=nad.fiscalyear_mon --renewal opportunity can be renewed even in the same month as new added
and nad.include_flg=True
--No need if a parent was Upsell, we add Price Increase based on full renewal amount added or not (ad)
--
where
fb.bucket in (
'Sales : Reduction : ARR',
'Sales : Reduction : Biz Dev')
)
--
,expected_reduced_monthly as (
select * from expected_reduced_monthly_cancellation
union all
select * from expected_reduced_monthly_reduction)
--
--==
--Booking
,booking_monthly as (
select
'MonthlyBooking' record_type,
fb.mon_year,
fb.mon_lastday,
fb.fiscalyear,
fb.fiscalyear_mon,
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
fb.bucket,
fb.amount,
true include_flg,
0 audit_id,
false new_opp_this_fy_flg --N/A for this category
from {{ ref('stg_revenue') }} fb
join dim_month m on m.mon_year = fb.mon_year
where
fb.bucket in (
'Sales : New Business : ARR',
'Sales : New Business : Biz Dev',
'Sales : Upsell : ARR',
'Sales : Upsell : Biz Dev',
'Sales : Renewal : ARR',
'Sales : Renewal : Biz Dev',
'Sales : New Business : NRR',
'Sales : New Business : Upfront Yrs>3',
'Sales : New Business : Upfront yr 2&3',
'Sales : Renewal : NRR',
'Sales : Renewal : Upfront Yr 2&3',
'Sales : Renewal : Upfront Yrs>3',
'Sales : Upsell : NRR',
'Sales : Upsell : Upfront Yr 2&3',
'Sales : Upsell : Upfront Yrs>3',
'Sales : Reseller ARR Renewal',
'Sales : Reseller ARR Upsell'
)
)
--
,final_data as
(
select
*
from starting_data
union all
select
*
from expected_add_monthly
union all
select
*
from expected_reduced_monthly
union all
select
*
from booking_monthly
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
from final_data
 where {{ month_range_to_load() }}