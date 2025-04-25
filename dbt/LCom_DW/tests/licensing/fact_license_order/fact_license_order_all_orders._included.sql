
select orderid from {{ ref("stg_license_orders") }}
except
select order_id from {{ ref("fact_license_order") }} 