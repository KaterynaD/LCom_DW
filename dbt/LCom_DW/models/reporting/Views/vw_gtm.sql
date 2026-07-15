{{ config(materialized='view', bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]) }}

with
deals_combined as (
select
dol.opportunity_id,
LISTAGG(dol.opportunity_line_id, ',') opportunity_line_id,
dol.business_type_opty_product,
dol.sfdc_product_id,
dol.total_price,
dol.unit_price,
dol.list_price,
sum(dol.quantity) quantity,
dol.additional_discount_amount,
dol.additional_discount_rate,
dol.additional_discount_type,
dol.total_discount_amount,
dol.total_discount_rate
from {{ ref("dim_opportunity_line") }} dol
group by all
)
,rawdata as (
select
fo.created_date,
fo.close_date,
fo.start_date,
fo.end_date,
fo.subscription_term,
fo.Contract_type,
fo.invoiced_date,
fo.stage_name,
fo.opp_record_type,
fo.opportunity_id,
fo.name as opportunity_name,
fo.opportunity_number,
fo.owner_id as opportunity_owner_id,
fo.account_id,
fo.multi_year_discount_rate,
case when fo.name like '%LOI%' then 'Yes' else 'No' end as is_LOI,
ecommerce_cart as EComm,
dol.opportunity_line_id,
dol.business_type_opty_product as bucket,
dol.sfdc_product_id,
dol.total_price,
dol.unit_price,
dol.list_price,
dol.quantity,
dol.additional_discount_amount,
dol.additional_discount_rate,
dol.additional_discount_type,
dol.total_discount_amount,
dol.total_discount_rate
from {{ ref("fact_opportunity") }} fo
join deals_combined dol
on fo.opportunity_id = dol.opportunity_id
where not(fo.name ilike '%NEGATIVE OPP%' or fo.name ilike '%REPLACEMENT OPP%')
)
,data as (
select
o.created_date,
o.close_date,
o.start_date,
o.end_date,
o.subscription_term,
o.Contract_type,
o.invoiced_date,
o.stage_name,
o.opp_record_type,
o.opportunity_id,
o.opportunity_name,
o.opportunity_number,
o.opportunity_owner_id,
o.account_id,
a.sfdc_ultimate_parent_id,
o.multi_year_discount_rate,
o.is_LOI,
o.EComm,
o.opportunity_line_id,
o.sfdc_product_id,
o.bucket,
sum(case
when o.bucket in (
'Sales : New Business : ARR',
'Sales : New Business : Biz Dev',
'Sales : Renewal : ARR',
'Sales : Reseller ARR Renewal',
'Sales : Renewal : Biz Dev',
'Sales : Upsell : ARR',
'Sales : Reseller ARR Upsell',
'Sales : Upsell : Biz Dev'
)
then o.total_price else 0
end) as arr,
sum(case
when o.bucket not in (
'Sales : New Business : ARR',
'Sales : New Business : Biz Dev',
'Sales : Renewal : ARR',
'Sales : Reseller ARR Renewal',
'Sales : Renewal : Biz Dev',
'Sales : Upsell : ARR',
'Sales : Reseller ARR Upsell',
'Sales : Upsell : Biz Dev'
)
then o.total_price else 0
end) as nrr,
-- 
--
o.unit_price,
o.list_price,
o.quantity,
o.additional_discount_amount,
o.additional_discount_rate,
o.additional_discount_type,
o.total_discount_amount,
o.total_discount_rate
from rawdata o
join {{ ref("dim_account") }} a
on o.account_id = a.account_id
group by all
)
,customer_since as (
select
sfdc_ultimate_parent_id,
min(invoiced_date) dt
from data
where stage_name ilike '%won%'
and invoiced_date>'1900-01-01'
group by sfdc_ultimate_parent_id
)
,customer_account_since as (
select
account_id,
min(invoiced_date) dt
from data
where stage_name ilike '%won%'
and invoiced_date>'1900-01-01'
group by account_id
)
,final_data as (
select
created_date,
close_date,
start_date,
end_date,
subscription_term,
Contract_type,
invoiced_date,
stage_name,
opp_record_type,
opportunity_id,
opportunity_name,
opportunity_number,
opportunity_owner_id,
data.sfdc_ultimate_parent_id,
customer_since.dt customer_since_date,
data.account_id,
customer_account_since.dt account_customer_since_date,
multi_year_discount_rate,
is_LOI,
EComm,
opportunity_line_id,
sfdc_product_id,
bucket,
nrr,
arr,
unit_price,
list_price,
quantity,
additional_discount_amount,
additional_discount_rate,
additional_discount_type,
total_discount_amount,
total_discount_rate
from data
left outer join customer_since
on data.sfdc_ultimate_parent_id = customer_since.sfdc_ultimate_parent_id
left outer join customer_account_since
on data.account_id = customer_account_since.account_id
)
select
 close.mon_year mon_year
,close.mon_lastday mon_lastday
,close.fiscalyear fiscalyear
,close.fiscalyear_mon fiscalyear_mon
--
,ds.created_date
,ds.close_date
,ds.start_date
,ds.end_date
,ds.subscription_term
,coalesce(nullif(ds.Contract_type,'Unknown'),'Not Set') as Contract_type
,case when ds.invoiced_date='1900-01-01' then null else ds.invoiced_date end invoiced_date
,ds.stage_name
,ds.opp_record_type
,ds.opportunity_id
,ds.opportunity_name
,ds.opportunity_number
--
,e.name as opportunity_owner
,eh.name as opportunity_owner_on_deal_close
--
,ds.multi_year_discount_rate
,ds.is_LOI
,coalesce(nullif(ds.EComm,'Unknown'),'Not EComm') as EComm
,ds.sfdc_ultimate_parent_id customer_id
,ds.customer_since_date
,ds.account_id
,ds.account_customer_since_date
,ds.bucket
,ds.opportunity_line_id
,ds.sfdc_product_id
,ds.nrr
,ds.arr
,ds.quantity
,ds.list_price
,ds.unit_price
,ds.additional_discount_amount
,ds.additional_discount_rate
,case when ds.additional_discount_type='Unknown' then '' else ds.additional_discount_type end as additional_discount_type
,ds.total_discount_amount
,ds.total_discount_rate
--
,p.sfdc_product_name
,p.lcom_suite
,p.sfdc_product_family
,p.sfdc_product_sub_family
--
,a.sfdc_account_id
,a.sfdc_name as account_name
,a.sfdc_billing_country as account_country
,a.sfdc_billing_state as account_state
,a.sfdc_county_name as account_county
,a.sfdc_owner_name_text as account_owner
,ah.sfdc_owner_name_text as account_owner_on_deal_close
,case when a.sfdc_district_enrollment=0 then a.sfdc_school_enrollment else a.sfdc_district_enrollment end as account_enrollment
,case when (a.sfdc_state_initiative or a.sfdc_state_initiative_school) then true else false end as account_state_initiative
,a.sfdc_urban_rural as acount_locale
,a.sfdc_customer_level as account_tier
--
,c.sfdc_account_id sfdc_customer_id
,c.sfdc_name as customer_name
,c.sfdc_billing_country as customer_country
,c.sfdc_billing_state as customer_state
,c.sfdc_county_name as customer_county
,c.sfdc_owner_name_text as customer_owner
,ch.sfdc_owner_name_text as customer_owner_on_deal_close
,case when c.sfdc_district_enrollment=0 then c.sfdc_school_enrollment else c.sfdc_district_enrollment end as customer_enrollment
,case when (c.sfdc_state_initiative or c.sfdc_state_initiative_school) then true else false end as customer_state_initiative
,c.sfdc_urban_rural as customer_locale
,c.sfdc_customer_level as customer_tier
--
from final_data ds
join {{ ref("fact_opportunity_history") }} foh
on ds.opportunity_id = foh.opportunity_id
and ds.close_date between foh.fromdate and foh.todate
join {{ ref("dim_account") }} a
on ds.account_id = a.account_id
join {{ ref("dim_account_history") }} ah
on ds.account_id = ah.account_id
and ds.close_date between ah.fromdate and ah.todate
join {{ ref("dim_account") }} c
on ds.sfdc_ultimate_parent_id = c.sfdc_account_id
join {{ ref("dim_account_history") }} ch
on c.account_id = ch.account_id
and ds.close_date between ch.fromdate and ch.todate
join {{ ref("dim_sfdc_product") }} p
on ds.sfdc_product_id = p.sfdc_product_id
join {{ ref("dim_calendar") }} close
on close.cal_date = ds.close_date
join {{ ref("dim_employee") }} e
on ds.opportunity_owner_id = e.employee_id
join {{ ref("dim_employee") }} eh
on foh.owner_id = eh.employee_id
where 
((ds.stage_name ilike '%won%' and ds.invoiced_date!='1900-01-01') or ds.stage_name ilike '%lost%')
and ds.close_date <= current_date

