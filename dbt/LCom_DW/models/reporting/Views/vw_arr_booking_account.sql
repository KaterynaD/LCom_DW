{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}
 
with 
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
from {{ ref("vw_fact_arr") }} f
join {{ ref("dim_account") }} a
on f.account_id = a.account_id
where  f.arr_type = 'Preliminary'
and f.record_type = 'ARR'
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