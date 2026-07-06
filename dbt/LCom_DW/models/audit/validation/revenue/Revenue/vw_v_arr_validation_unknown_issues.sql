{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select distinct
    v.validation_issue,
    v.opportunity_id
from {{ ref('dim_arr_validation') }} v
where v.known_issue = 'No'