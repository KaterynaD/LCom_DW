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
,final_data as (
select
combined_data.opportunity_id,
combined_data.sfdc_product_id,
combined_data.bucket as bucket,
combined_data.total_price,
combined_data.parent_total_price
from combined_data
)
select 
opportunity_id::varchar(300),
sfdc_product_id::varchar(300),
bucket::varchar(100),
total_price::numeric(38,10),
parent_total_price::numeric(38,10)
from final_data