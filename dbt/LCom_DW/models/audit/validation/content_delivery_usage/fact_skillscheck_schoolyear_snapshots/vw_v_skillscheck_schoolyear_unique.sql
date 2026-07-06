{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

-- Uniqueness test for the configured unique_key
-- Ensures no duplicate rows for the unique grain
select
  schoolyear,
  organization_district_id,
  user_account_id,
  assessment_set_id,
  count(*) as row_count
from {{ ref('fact_skillscheck_schoolyear_snapshots') }}
group by 1,2,3,4
having count(*) > 1