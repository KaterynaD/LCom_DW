{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select id from {{ source('fivetran_salesforce_quickstart', 'account') }}
except
select SFDC_account_id from {{ ref("dim_account") }}