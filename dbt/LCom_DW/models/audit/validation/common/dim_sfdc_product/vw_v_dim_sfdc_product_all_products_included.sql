{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select id from {{ source("fivetran_salesforce_quickstart","product_2") }}
except
select sfdc_product_id from {{ ref("dim_sfdc_product") }}