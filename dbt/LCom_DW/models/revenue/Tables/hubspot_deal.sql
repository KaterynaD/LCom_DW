{{
    config(

        materialized='table',        
        dist='deal_id',
        sort='purchased_date'
        
        )
}}

select
d.deal_id::varchar(300),
isnull(d.property_dealname,'{{ var("default_varchar") }}')::varchar(256) deal_name,
isnull((d.property_cart_purchased_date AT TIME ZONE 'utc'), '{{ var("default_date") }}')::date as purchased_date,
isnull(d.property_amount,{{ var("default_numeric") }})::numeric(35,10) as amount,
isnull(d.property_hs_salesforceopportunityid,'{{ var("default_ID") }}')::varchar(300) as sfdc_opportunity_id,
isnull((d.property_invoiced_date_c AT TIME ZONE 'utc'), '{{ var("default_date") }}')::date  as sfdc_invoiced_date,
isnull(d.property_salesforcelastsynctime AT TIME ZONE 'utc', '{{ var("default_date") }}')::timestamp as sfdc_last_synctime,
isnull(d.property_ecommerce_renewal,'{{ var("default_boolean") }}')::boolean as ecomm_renewal,
isnull(replace(property_ecommerce_invoice_link_sync , 'https://info.learning.com/cart/', ''),'{{ var("default_varchar") }}')::varchar(300) invoice_link_id,
'EComm'::varchar(5) deal_type,
'{{ var("loaddate") }}'::TIMESTAMP WITHOUT TIME ZONE as loaddate
from {{ source('fivetran_hubspot', 'deal') }} d
where (d.property_ecommerce_cart is True or d.property_ecommerce_renewal is True)
and is_deleted is False
and _fivetran_deleted is false