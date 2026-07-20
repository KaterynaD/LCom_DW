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
case when fo.subscription_term >= 24 then 'Yes' else 'No' end as is_multiyear,
case when fo.subscription_term < 12 then 'Yes' else 'No' end as is_shortterm,
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
case when fo.name ilike '%NEGATIVE OPP%' or fo.name ilike '%REPLACEMENT OPP%' then 'Yes' else 'No' end as is_negative_or_replacement,
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
)
,data as (
select
o.created_date,
o.close_date,
o.start_date,
o.end_date,
o.subscription_term,
o.is_multiyear,
o.is_shortterm,
o.Contract_type,
o.invoiced_date,
o.stage_name,
o.opp_record_type,
o.opportunity_id,
o.opportunity_name,
o.opportunity_number,
o.opportunity_owner_id,
o.account_id,
o.multi_year_discount_rate,
o.is_LOI,
o.is_negative_or_replacement,
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
o.total_price,
o.list_price,
o.quantity,
o.additional_discount_amount,
o.additional_discount_rate,
o.additional_discount_type,
o.total_discount_amount,
o.total_discount_rate
from rawdata o
group by all
)
select
created_date,
close_date,
start_date,
end_date,
subscription_term,
is_multiyear,
is_shortterm,
Contract_type,
invoiced_date,
stage_name,
opp_record_type,
opportunity_id,
opportunity_name,
opportunity_number,
opportunity_owner_id,
account_id,
multi_year_discount_rate,
is_LOI,
is_negative_or_replacement, 
EComm,
opportunity_line_id,
sfdc_product_id,
bucket,
nrr,
arr,
total_price,
list_price,
quantity,
additional_discount_amount,
additional_discount_rate,
additional_discount_type,
total_discount_amount,
total_discount_rate
from data


