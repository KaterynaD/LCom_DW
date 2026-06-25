{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}
 
with opportunities_issues as (
select 
a.opportunity_id,
listagg(i.issue, ', ') WITHIN GROUP (ORDER BY i.issue) AS  issues
from {{ ref('dim_arr_audit') }} a
join {{ ref('dim_arr_issue') }} i
on a.issue_id = i.issue_id
group by a.opportunity_id
),
data as (
select 
f.mon_year,
f.mon_lastday,
f.fiscalyear,
f.fiscalyear_mon ,
f.account_id,
a.sfdc_account_id,
'ARR' record_type,
sum(f.arr_amount) as amount
from {{ ref("fact_arr") }} f
left outer join opportunities_issues i
on f.opportunity_id = i.opportunity_id
join {{ ref("dim_account") }} a
on f.account_id = a.account_id
where  f.arr_type = 'Preliminary'
and f.record_type = 'ARR'
and getdate() between f.arr_activation_date and f.arr_deactivation_date
      and isnull(i.issues,'Valid') not ilike '%negative opp%'
      and isnull(i.issues,'Valid') not ilike '%replacement opp%'  
group by 
f.mon_year,
f.mon_lastday,
f.fiscalyear,
f.fiscalyear_mon ,
f.account_id,
a.sfdc_account_id
union all
select 
f.mon_year,
f.mon_lastday,
f.fiscalyear,
f.fiscalyear_mon ,
f.account_id,
a.sfdc_account_id,
'Booking' record_type,
sum(f.total_price) as amount
from {{ ref("fact_booking") }} f
join {{ ref("dim_account") }} a
on f.account_id = a.account_id
group by 
f.mon_year,
f.mon_lastday,
f.fiscalyear,
f.fiscalyear_mon ,
f.account_id,
a.sfdc_account_id
)
select *
from data