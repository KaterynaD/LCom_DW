{{ config(materialized='view', bind=False) }}

with
/*==============================================================================================*/
/*====================================  HUBSPOT  ===============================================*/
/*==============================================================================================*/
data_product as (
    select
        'fivetran_hubspot' as schema_name,
        'product' as table_name,
        count(1) as total_rows,
        max(property_createdate)::date as max_created_date
    from rawdata.fivetran_hubspot.product
)
,
data_payment as (
    select
        'fivetran_hubspot' as schema_name,
        'payment' as table_name,
        count(1) as total_rows,
        max(property_hs_createdate)::date as max_created_date
    from rawdata.fivetran_hubspot.payment
)
,
data_line_item as (
    select
        'fivetran_hubspot' as schema_name,
        'line_item' as table_name,
        count(1) as total_rows,
        max(property_createdate)::date as max_created_date
    from rawdata.fivetran_hubspot.line_item
)
,
data_invoice as (
    select
        'fivetran_hubspot' as schema_name,
        'invoice' as table_name,
        count(1) as total_rows,
        max(property_hs_createdate)::date as max_created_date
    from rawdata.fivetran_hubspot.invoice
)
,
data_deal as (
    select
        'fivetran_hubspot' as schema_name,
        'deal' as table_name,
        count(1) as total_rows,
        max(property_hs_createdate)::date as max_created_date
    from rawdata.fivetran_hubspot.deal
)
,
data_contact as (
    select
        'fivetran_hubspot' as schema_name,
        'contact' as table_name,
        count(1) as total_rows,
        max(property_createdate)::date as max_created_date
    from rawdata.fivetran_hubspot.contact
)
,
data_company as (
    select
        'fivetran_hubspot' as schema_name,
        'company' as table_name,
        count(1) as total_rows,
        max(property_createdate)::date as max_created_date
    from rawdata.fivetran_hubspot.company
)

select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_hubspot.product f
join data_product
    on f.property_createdate::date = data_product.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_hubspot.payment f
join data_payment
    on f.property_hs_createdate::date = data_payment.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_hubspot.line_item f
join data_line_item
    on f.property_createdate::date = data_line_item.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_hubspot.invoice f
join data_invoice
    on f.property_hs_createdate::date = data_invoice.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_hubspot.deal f
join data_deal
    on f.property_hs_createdate::date = data_deal.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_hubspot.contact f
join data_contact
    on f.property_createdate::date = data_contact.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_hubspot.company f
join data_company
    on f.property_createdate::date = data_company.max_created_date
group by all
