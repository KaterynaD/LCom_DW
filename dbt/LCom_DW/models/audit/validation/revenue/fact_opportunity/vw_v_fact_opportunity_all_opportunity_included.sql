{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select id from {{ source('fivetran_salesforce_quickstart', 'opportunity') }} where test_account_c = false
except
select opportunity_id from {{ ref('fact_opportunity') }}