{{ config(
        
        materialized='table',
        dist='all',
        sort='product_category'
)
 }}

select 
product_type::varchar(3),
product_category::varchar(150),
product_name::varchar(150),
product_id::varchar(50),
fromdate::date,
todate::date,
loaddate::timestamp
from {{ ref('stg_product_category') }}
where product_type is not null
