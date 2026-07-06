{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select opportunity_id FROM {{ ref("fact_opportunity") }}
except
select opportunity_id FROM {{ ref("fact_opportunity_history") }}