select distinct opportunity_id
from {{ ref("fact_revenue_monthly_snapshots") }}
where record_type!='MonthlyBooking'
and renewal_stage_name = 'Closed Lost'
and mon_year > to_char(renewal_close_date,'yyyymm')