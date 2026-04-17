-- Row count sanity check: alerts if row count is unexpectedly low
select count(*) as row_count
from {{ ref('fact_skillscheck_schoolyear_snapshots') }}
-- Optionally, set a threshold for minimum expected rows (edit as needed)
having count(*) < 100
