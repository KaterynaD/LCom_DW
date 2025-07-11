select lower(skuid) from {{ source("staging","sku") }} 
except
select sku_id from {{ ref("dim_lcom_sku") }}