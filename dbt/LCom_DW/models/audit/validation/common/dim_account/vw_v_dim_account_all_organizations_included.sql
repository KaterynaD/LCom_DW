{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select organization_id from {{ source("dbo","organization") }} 
except
select lcom_organization_id from {{ ref("dim_account") }}