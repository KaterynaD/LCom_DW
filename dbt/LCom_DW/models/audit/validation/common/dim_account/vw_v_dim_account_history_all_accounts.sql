{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select account_id FROM {{ ref("dim_account") }}
except
select account_id FROM {{ ref("dim_account_history") }}