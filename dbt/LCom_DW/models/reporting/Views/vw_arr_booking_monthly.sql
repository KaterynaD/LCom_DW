{{ config(materialized='view',
   bind=False
)
 }}
 
with data as (
select
arr_type,    
record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
account_id,
opportunity_id,
sfdc_product_id,
Bucket,
Bucket_SFDC,
total_price,
parent_total_price,
arr_amount,
arr_activation_date,
arr_deactivation_date
from  {{ ref('fact_arr') }}
union all
select 
'ARR Target' arr_type,    
'Target'  record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
'{{ var("default_ID") }}' account_id,
null opportunity_id,
'{{ var("default_ID") }}' sfdc_product_id,
'Target' Bucket,
'Target' Bucket_SFDC,
null total_price,
null parent_total_price,
case when fiscalyear = '2025/2026' then 25800000 else 0 end arr_amount,
null arr_activation_date,
null arr_deactivation_date
from {{ ref('dim_month') }}
where mon_year<=TO_CHAR(GETDATE(), 'YYYYMM')::int
union all
select
'Booking' arr_type,    
record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
account_id,
opportunity_id,
sfdc_product_id,
Bucket,
Bucket Bucket_SFDC,
total_price,
null parent_total_price,
total_price arr_amount,
'1900-01-01' as arr_activation_date,
'3000-01-01' as arr_deactivation_date
from {{ ref('fact_booking') }}
)
select
f.arr_type data_type,
f.record_type,
f.mon_year,
f.mon_lastday,
f.fiscalyear,
f.fiscalyear_mon,
f.opportunity_id,
o.opportunity_number,
o.name as opportunity_name,
o.stage_name,
a.sfdc_account_id,
a.sfdc_state_initiative account_state_initiative,
a.sfdc_ultimate_parent_id,
ua.sfdc_state_initiative ultimate_parent_account_state_initiative,
case when o.invoiced_date='1900-01-01' then null else o.invoiced_date end as invoiced_date,
o.close_date,
o.start_date,
case when o.end_date in ('3000-01-01','1900-01-01') then null else o.end_date end as end_date,
f.arr_activation_date,
f.arr_deactivation_date,
ro.opportunity_id as renewal_opportunity_id,
ro.stage_name as renewal_stage_name,
ro.invoiced_date  as renewal_invoiced_date,
ro.close_date  as renewal_close_date,
ro.start_date  as renewal_start_date,
ro.end_date renewal_end_date,
f.Bucket,
f.Bucket_SFDC,
f.total_price ,
f.parent_total_price,
f.arr_amount as amount,
f.sfdc_product_id,
p.sfdc_product_name,
p.lcom_suite,
p.sfdc_product_family,
p.sfdc_product_sub_family,
ah.sfdc_name as account_name,
uah.sfdc_name as ultimate_parent_account_name,
uah.sfdc_billing_state state,
uah.sfdc_billing_country country,
case when uah.sfdc_district_enrollment=0 then uah.sfdc_school_enrollment else uah.sfdc_district_enrollment end as district_enrollment,
case when (uah.sfdc_state_initiative or uah.sfdc_state_initiative_school) then true else false end as state_initiative,
uah.sfdc_urban_rural as urban_rural ,
uah.sfdc_owner_name_text as account_owner_name,
ua.sfdc_owner_name_text as current_account_owner_name
from data f
join {{ ref('dim_account') }} a
on f.account_id = a.account_id
join {{ ref('dim_account') }} ua
on a.sfdc_ultimate_parent_id = ua.sfdc_account_id
join {{ ref('dim_account_history') }} uah
on ua.account_id = uah.account_id
and f.mon_lastday between uah.fromdate and uah.todate
join {{ ref('dim_account_history') }} ah
on f.account_id = ah.account_id
and f.mon_lastday between ah.fromdate and ah.todate
join {{ ref('dim_sfdc_product') }} p
on f.sfdc_product_id=p.sfdc_product_id
and f.mon_lastday between ah.fromdate and ah.todate
left outer /*to include Target data*/ join {{ ref('fact_opportunity') }} o
on f.opportunity_id = o.opportunity_id
left outer join {{ ref('fact_opportunity') }} ro
on o.renewal_opportunity_id = ro.opportunity_id
where f.mon_year<=TO_CHAR(GETDATE(), 'YYYYMM')::int

