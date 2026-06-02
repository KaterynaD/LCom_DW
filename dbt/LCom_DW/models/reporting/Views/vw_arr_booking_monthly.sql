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
start_date as start_date_adjusted,
end_date as end_date_adjusted,
renewal_start_date as renewal_start_date_adjusted,
max_parent_end_date as max_parent_end_date_adjusted,
arr_activation_date,
arr_deactivation_date
from  {{ ref('fact_arr') }}
where record_type!='ARR'
union all
select
arr_type,    
'ARR-Starting' as record_type,
m.next_mon_year   as mon_year,
m.next_mon_lastday as mon_lastday,
m.next_mon_fiscalyear as fiscalyear,
m.next_mon_fiscalyear_mon as  fiscalyear_mon,
account_id,
opportunity_id,
sfdc_product_id,
case 
 when Bucket ilike '%ARR%' then 'Starting: ARR' 
 else 'Starting: Biz Dev' 
end as Bucket,
Bucket_SFDC,
total_price,
parent_total_price,
arr_amount,
start_date as start_date_adjusted,
end_date as end_date_adjusted,
renewal_start_date as renewal_start_date_adjusted,
max_parent_end_date as max_parent_end_date_adjusted,
arr_activation_date,
arr_deactivation_date
from  {{ ref('fact_arr') }} fa
join {{ ref('dim_month') }} m
on fa.mon_year = m.mon_year
where record_type='ARR'
and DATE_PART(month, fa.mon_lastday) <> 6
union all
select
arr_type,    
'ARR-Ending' as record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
account_id,
opportunity_id,
sfdc_product_id,
case 
 when Bucket ilike '%ARR%' then 'Ending: ARR' 
 else 'Ending: Biz Dev' 
end as Bucket,
Bucket_SFDC,
total_price,
parent_total_price,
arr_amount,
start_date as start_date_adjusted,
end_date as end_date_adjusted,
renewal_start_date as renewal_start_date_adjusted,
max_parent_end_date as max_parent_end_date_adjusted,
arr_activation_date,
arr_deactivation_date
from  {{ ref('fact_arr') }}
where record_type='ARR'
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
null as start_date_adjusted,
null as end_date_adjusted,
null as renewal_start_date_adjusted,
null as max_parent_end_date_adjusted,
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
Bucket_SFDC,
total_price,
null parent_total_price,
total_price arr_amount,
'1900-01-01' as arr_activation_date,
'3000-01-01' as arr_deactivation_date,
null as start_date_adjusted,
null as end_date_adjusted,
null as renewal_start_date_adjusted,
null as max_parent_end_date_adjusted
from {{ ref('fact_booking') }}
)
,opportunities_issues as (
select 
a.opportunity_id,
listagg(i.issue, ', ') WITHIN GROUP (ORDER BY i.issue) AS  issues
from {{ ref('dim_arr_audit') }} a
join {{ ref('dim_arr_issue') }} i
on a.issue_id = i.issue_id
group by a.opportunity_id
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
f.start_date_adjusted,
f.end_date_adjusted,
f.renewal_start_date_adjusted,
f.max_parent_end_date_adjusted,
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
a.sfdc_name as account_name,
ua.sfdc_name as ultimate_parent_account_name,
ua.sfdc_billing_state state,
ua.sfdc_billing_country country,
case when ua.sfdc_district_enrollment=0 then ua.sfdc_school_enrollment else ua.sfdc_district_enrollment end as district_enrollment,
case when (ua.sfdc_state_initiative or ua.sfdc_state_initiative_school) then true else false end as state_initiative,
ua.sfdc_urban_rural as urban_rural ,
ua.sfdc_owner_name_text as current_account_owner_name ,
o.subscription_term,
o.progressive_billing,
o.progressive_payment_amount_2,
o.progressive_payment_amount_3,
o.progressive_payment_amount_4,
o.progressive_payment_amount_5,
o.progressive_payment_date_2,
o.progressive_payment_date_3,
o.progressive_payment_date_4,
o.progressive_payment_date_5,
case when f.arr_type!='Booking' then isnull(i.issues, 'Valid') else 'Valid' end as issues
from data f
join {{ ref('dim_account') }} a
on f.account_id = a.account_id
join {{ ref('dim_account') }} ua
on a.sfdc_ultimate_parent_id = ua.sfdc_account_id
join {{ ref('dim_sfdc_product') }} p
on f.sfdc_product_id=p.sfdc_product_id
left outer /*to include Target data*/ join {{ ref('fact_opportunity') }} o
on f.opportunity_id = o.opportunity_id
left outer join {{ ref('fact_opportunity') }} ro
on o.renewal_opportunity_id = ro.opportunity_id
left outer join opportunities_issues i
on f.opportunity_id = i.opportunity_id
where f.mon_year<=TO_CHAR(GETDATE(), 'YYYYMM')::int

