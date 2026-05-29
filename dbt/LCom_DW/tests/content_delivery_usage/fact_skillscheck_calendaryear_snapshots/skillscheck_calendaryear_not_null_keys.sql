-- Non-nullness test for key dimensions
select *
from {{ ref('fact_skillscheck_calendaryear_snapshots') }}
where calendaryear is null
   or organization_district_id is null
   or user_account_id is null
   or assessment_set_id is null
