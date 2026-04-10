{{
    config(

        materialized='table',        
        dist='opportunity_id' 
        
        )
}}

with 
/*Opportunity Product Lines*/
raw_ol as (
select
fo.opportunity_id,
dol.sfdc_product_id,
dol.business_type_opty_product ,
dol.total_price
from {{ ref("fact_opportunity") }} fo
join {{ ref("stg_valid_opportunities") }} ooi
on fo.opportunity_id = ooi.opportunity_id
join {{ ref("dim_opportunity_line") }} dol
on fo.opportunity_id = dol.opportunity_id
where
(
dol.business_type_opty_product ilike '%arr%'
or dol.business_type_opty_product ilike '%biz_dev%'
)
and dol.business_type_opty_product not ilike '%upfront%'
)
, ol as (
select
opportunity_id,
sfdc_product_id,
business_type_opty_product ,
sum(total_price) total_price
from raw_ol
group by
opportunity_id,
sfdc_product_id,
business_type_opty_product
)
/*Parent Opportunity Product Lines*/
,pol as (
select
fo.renewal_opportunity_id as opportunity_id,
dol.sfdc_product_id,
dol.business_type_opty_product ,
sum(dol.total_price) parent_total_price
from {{ ref("fact_opportunity") }} fo
join {{ ref("stg_valid_opportunities") }} ooi
on fo.opportunity_id = ooi.opportunity_id
join {{ ref("dim_opportunity_line") }} dol
on fo.opportunity_id = dol.opportunity_id
where
(
dol.business_type_opty_product ilike '%arr%'
or dol.business_type_opty_product ilike '%biz_dev%'
)
and dol.business_type_opty_product not ilike '%upfront%'
group by
fo.renewal_opportunity_id,
dol.sfdc_product_id,
dol.business_type_opty_product
)
/*Opportunity and Parent Opportunity Totals based on Product Lines*/
,combined_data as (
select
coalesce(rol.opportunity_id , pol.opportunity_id) as opportunity_id,
coalesce(rol.sfdc_product_id, pol.sfdc_product_id) as sfdc_product_id,
coalesce(rol.business_type_opty_product,pol.business_type_opty_product) as bucket,
isnull(rol.total_price, 0) total_price,
isnull(pol.parent_total_price, 0) parent_total_price
from ol rol
full outer join pol
on rol.opportunity_id = pol.opportunity_id
and rol.sfdc_product_id = pol.sfdc_product_id
and rol.business_type_opty_product = pol.business_type_opty_product
)
/*max parents end date for each opportunity*/
,parents_info as (
select
pfo.renewal_opportunity_id opportunity_id,
max(pfo.end_date) max_parent_end_date
from {{ ref("fact_opportunity") }} pfo
join {{ ref("stg_valid_opportunities") }} ooi
on pfo.opportunity_id = ooi.opportunity_id
where pfo.renewal_opportunity_id!='Unknown'
group by pfo.renewal_opportunity_id
)
,final_data as (
select
combined_data.opportunity_id,
case when parents_info.max_parent_end_date is not null then true else false end HasParent,
combined_data.sfdc_product_id,
combined_data.bucket as bucket,
combined_data.total_price,
combined_data.parent_total_price,
isnull(parents_info.max_parent_end_date, '{{ var("default_date") }}') as max_parent_end_date
from combined_data
left outer join parents_info
on combined_data.opportunity_id = parents_info.opportunity_id
)
select 
opportunity_id::varchar(300),
HasParent::boolean,
sfdc_product_id::varchar(300),
bucket::varchar(100),
total_price::numeric(38,10),
parent_total_price::numeric(38,10),
max_parent_end_date::date
from final_data