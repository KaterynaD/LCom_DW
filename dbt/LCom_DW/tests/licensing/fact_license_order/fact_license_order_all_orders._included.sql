
select orderid from {{ source("staging","license_order") }}
except
select order_id from {{ ref("fact_license_order") }} 