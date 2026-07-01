{{
    config(

        materialized='table',        
        dist='deal_id',
        sort='purchased_date'
        
        )
}}

with a as (
  select 
    dc.deal_id,
    max(c.property_name) as property_name --precaution for multiple company names per deal
  from {{ source('fivetran_hubspot', 'company') }} c
  join {{ source('fivetran_hubspot', 'deal_company') }}  dc
  on c.id = dc.company_id
  where dc.type_id = 5 --deal_to_company
  and c.is_deleted is False
  and c._fivetran_deleted is false
  group by dc.deal_id
)
select
d.deal_id::varchar(300),
isnull(d.property_dealname,'{{ var("default_varchar") }}')::varchar(256) deal_name,
isnull(a.property_name,'Unknown')::varchar(256) account_name,
isnull(d.property_billing_state_c,'Unknown')::varchar(256) billing_state,
isnull((d.property_cart_purchased_date AT TIME ZONE 'utc'), '{{ var("default_date") }}')::date as purchased_date,
isnull(d.property_amount,{{ var("default_numeric") }})::numeric(35,10) as amount,
isnull(d.property_hs_salesforceopportunityid,'{{ var("default_ID") }}')::varchar(300) as sfdc_opportunity_id,
isnull((d.property_invoiced_date_c AT TIME ZONE 'utc'), '{{ var("default_date") }}')::date  as sfdc_invoiced_date,
isnull(d.property_salesforcelastsynctime AT TIME ZONE 'utc', '{{ var("default_date") }}')::timestamp as sfdc_last_synctime,
isnull(d.property_ecommerce_renewal,'{{ var("default_boolean") }}')::boolean as ecomm_renewal,
isnull(replace(property_ecommerce_invoice_link_sync , 'https://info.learning.com/cart/', ''),'{{ var("default_varchar") }}')::varchar(300) invoice_link_id,
case when ecomm_renewal then 'EComm Renewal'::varchar(20) else 'EComm'::varchar(20) end as deal_type,
'{{ var("loaddate") }}'::TIMESTAMP WITHOUT TIME ZONE as loaddate
from {{ source('fivetran_hubspot', 'deal') }} d
left outer join a
on d.deal_id = a.deal_id
where (d.property_ecommerce_cart is True or d.property_ecommerce_renewal is True)
and d.is_deleted is False
and d._fivetran_deleted is false
