{{ config(materialized='view',
   bind=False
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
where 
mon_year<=to_char(Getdate(),'yyyymm')::int
)
,ARR_data as
(
--extend Starting to each month in the fiscal year for running total 
select
'ARR' record_type,
mon.mon_year,
mon.mon_lastday,
mon.fiscalyear,
mon.fiscalyear_mon,
opportunity_id,
stage_name,
opp_record_type ,
sfdc_account_id,
sfdc_state_initiative,
sfdc_ultimate_parent_id,
invoiced_date ,
close_date,
start_date,
end_date,
renewal_opportunity_id,
renewal_stage_name,
renewal_invoiced_date,
renewal_close_date,
disable_auto_renewal_opp,
license_unenforced,
Bucket_original,
Bucket,
amount,
include_flg,
audit_id,
new_opp_this_fy_flg,
loaddate 
from {{ ref('fact_revenue_monthly_snapshots') }} st
join dim_month mon
on st.mon_lastday between mon.fiscalyear_startdate and mon.fiscalyear_enddate
where st.record_type='ARR-Starting'
union all
--extend Expected Add Monthly to each month in the fiscal year for running total 
select
'ARR' record_type,
mon.mon_year,
mon.mon_lastday,
mon.fiscalyear,
mon.fiscalyear_mon,
opportunity_id,
stage_name,
opp_record_type ,
sfdc_account_id,
sfdc_state_initiative,
sfdc_ultimate_parent_id,
invoiced_date ,
close_date,
start_date,
end_date,
renewal_opportunity_id,
renewal_stage_name,
renewal_invoiced_date,
renewal_close_date,
disable_auto_renewal_opp,
license_unenforced,
Bucket_original,
Bucket,
amount,
include_flg,
audit_id,
new_opp_this_fy_flg,
loaddate 
from {{ ref('fact_revenue_monthly_snapshots') }} eam
join dim_month mon
on eam.fiscalyear=mon.fiscalyear
and eam.mon_lastday<=mon.mon_lastday
where eam.record_type='ARR-MonthlyAdded'
union all
--extend Expected Reduced Monthly to each month in the fiscal year for running total 
select
'ARR' record_type,
mon.mon_year,
mon.mon_lastday,
mon.fiscalyear,
mon.fiscalyear_mon,
opportunity_id,
stage_name,
opp_record_type ,
sfdc_account_id,
sfdc_state_initiative,
sfdc_ultimate_parent_id,
invoiced_date ,
close_date,
start_date,
end_date,
renewal_opportunity_id,
renewal_stage_name,
renewal_invoiced_date,
renewal_close_date,
disable_auto_renewal_opp,
license_unenforced,
Bucket_original,
Bucket,
amount,
include_flg,
audit_id,
new_opp_this_fy_flg,
loaddate 
from {{ ref('fact_revenue_monthly_snapshots') }} erm
join dim_month mon
on erm.fiscalyear=mon.fiscalyear
and erm.mon_lastday<=mon.mon_lastday
where erm.record_type='ARR-MonthlyReduced'
)
--
,Booking_data as (
--extend Actual data Monthly to each month in the fiscal year for running total 
select
'Booking' record_type,
mon.mon_year,
mon.mon_lastday,
mon.fiscalyear,
mon.fiscalyear_mon,
opportunity_id,
stage_name,
opp_record_type ,
sfdc_account_id,
sfdc_state_initiative,
sfdc_ultimate_parent_id,
invoiced_date ,
close_date,
start_date,
end_date,
renewal_opportunity_id,
renewal_stage_name,
renewal_invoiced_date,
renewal_close_date,
disable_auto_renewal_opp,
license_unenforced,
Bucket_original,
Bucket,
amount,
include_flg,
audit_id,
new_opp_this_fy_flg,
loaddate 
from {{ ref('fact_revenue_monthly_snapshots') }} ar
join dim_month mon
on ar.fiscalyear=mon.fiscalyear
and ar.mon_lastday<=mon.mon_lastday
where ar.record_type='MonthlyBooking'
)
--
,final_data as
(
select 
*
from ARR_data
union all
select 
*
from Booking_data
union all
select 
*
from {{ ref('fact_revenue_monthly_snapshots') }}
)
select 
record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
opportunity_id,
stage_name,
opp_record_type ,
sfdc_account_id,
sfdc_state_initiative,
sfdc_ultimate_parent_id,
invoiced_date ,
close_date,
start_date,
end_date,
renewal_opportunity_id,
renewal_stage_name,
renewal_invoiced_date,
renewal_close_date,
disable_auto_renewal_opp,
license_unenforced,
Bucket_original,
Bucket,
amount,
include_flg,
audit_id,
new_opp_this_fy_flg,
loaddate 
from final_data
