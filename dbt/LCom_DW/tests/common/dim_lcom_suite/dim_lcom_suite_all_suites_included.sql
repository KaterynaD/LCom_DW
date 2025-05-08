select distinct lower(lcom_suite_id) from {{ source("staging","sku_suite") }}
except
select suite_id from {{ ref("dim_lcom_suite") }}