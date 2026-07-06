{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select lower(skuid) from {{ source("staging","sku") }} 
except
select sku_id from {{ ref("dim_lcom_sku") }}