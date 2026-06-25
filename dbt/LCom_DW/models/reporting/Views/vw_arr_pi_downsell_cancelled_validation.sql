{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}
with multi_parents as (
    select 
ro.opportunity_id,
count(distinct o.opportunity_id) cnt_parents,
sum(case when dol.business_type_opty_product ilike '%upsell%' then 1 else 0 end) cnt_upsell_parents
from {{ ref("fact_opportunity") }} o
join {{ ref("fact_opportunity") }} ro
on o.renewal_opportunity_id = ro.opportunity_id
join {{ ref("dim_opportunity_line") }} dol
on o.opportunity_id = dol.opportunity_id
group by ro.opportunity_id
having count(distinct o.opportunity_id)>1)
,data as (
select
r.fiscalyear ,
r.arr_type,
r.bucket,
r.opportunity_id,
sum(r.arr_amount) arr_amount
from {{ ref("fact_arr") }} r
where
bucket in ('Placeholder for Price Increase or Downsell: ARR', 'Placeholder for Price Increase or Downsell: Biz Dev', 'Cancellation: Biz Dev', 'Cancellation: ARR')
and GetDate() between arr_activation_date and arr_deactivation_date
and record_type!='ARR'
group by all
)
,data_final as (
select 
fiscalyear,
arr_type,
data.opportunity_id,
case 
 when bucket ilike '%cancel%' then bucket
 when bucket not ilike '%cancel%' and arr_amount > 0 then replace(bucket,'Placeholder for Price Increase or Downsell:','Price Increase:')
 when bucket not ilike '%cancel%' and arr_amount < 0 then replace(bucket,'Placeholder for Price Increase or Downsell:','Reduction:')
end bucket,
arr_amount
from data
where arr_amount != 0
)
,pivot_data as (
select
    fiscalyear,
    arr_type,
    opportunity_id,
    sum(case when bucket  ilike '%increase%'   then arr_amount else 0 end) as price_increase_calculated,
    sum(case when bucket  ilike '%reduction%'     then arr_amount else 0 end) as downsell_calculated,
    sum(case when bucket  ilike '%cancel%'     then arr_amount else 0 end) as cancelled_calculated
from data_final
group by
    fiscalyear,
    arr_type,
    opportunity_id
)
,joined_data as (
select
fiscalyear,
arr_type,
fo.opportunity_id,
fo.opportunity_number,
fo.name as opportunity_name,
fo.stage_name,
case when fo.invoiced_date='1900-01-01' then null else fo.invoiced_date end as invoiced_date,
fo.close_date,
fo.start_date,
case when fo.end_date in ('3000-01-01','1900-01-01') then null else fo.end_date end as end_date,
fo.arr,
fo.Override_ARR,
da.account_id,
da.sfdc_account_id,
da.sfdc_name as account_name,
case when fo.stage_name != 'Closed Lost' then price_increase_calculated  else 0 end price_increase_calculated,
case when fo.stage_name != 'Closed Lost' then fo.price_increase_arr else 0 end price_increase_salesforce,
case when fo.stage_name != 'Closed Lost' then downsell_calculated else 0 end downsell_calculated,
case when fo.stage_name != 'Closed Lost' then fo.downsell  else 0 end downsell_salesforce,
case when fo.stage_name = 'Closed Lost' then cancelled_calculated  else 0 end cancelled_calculated,
case when fo.stage_name = 'Closed Lost' then -fo.true_arr_formula else 0 end cancelled_salesforce
from pivot_data as data
join {{ ref("fact_opportunity") }} fo 
on data.opportunity_id = fo.opportunity_id
join {{ ref('dim_account') }} da
on da.account_id = fo.account_id
)
select
distinct
fiscalyear,
arr_type,
jd.opportunity_id,
opportunity_number,
opportunity_name,
stage_name,
invoiced_date,
close_date,
start_date,
end_date,
arr,
account_id,
sfdc_account_id,
account_name,
case when mp.cnt_parents is null then 'N' else 'Y' end as isMultiParents,
case when mp.cnt_upsell_parents > 0 then 'Y' else 'N' end as hasUpsellParent,
case when abs(Override_ARR) > 0.01 then 'Y' else 'N' end as hasOverrideARR,
case when da.opportunity_id is not null then 'Y' else 'N' end as hasIssues,
price_increase_calculated,
price_increase_salesforce,
downsell_calculated,
downsell_salesforce,
cancelled_calculated,
cancelled_salesforce
from joined_data as jd
left outer join multi_parents as mp
on mp.opportunity_id = jd.opportunity_id
left outer join {{ ref("dim_arr_audit") }} da
on da.opportunity_id = jd.opportunity_id
where 
abs(price_increase_calculated - price_increase_salesforce)>0.1
or
abs(abs(downsell_calculated) - abs(downsell_salesforce))>0.1
or
abs(abs(cancelled_calculated) - abs(cancelled_salesforce))>0.1
