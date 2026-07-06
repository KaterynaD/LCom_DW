{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select case_id FROM {{ ref("fact_case") }}
except
select case_id FROM {{ ref("fact_case_history") }}