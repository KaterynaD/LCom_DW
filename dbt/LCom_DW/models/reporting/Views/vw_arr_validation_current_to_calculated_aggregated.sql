{{ config(materialized='view',
   bind=False
)
 }}
 
with current as (
select
r.arr_type,
socr.parent_opportunities,
r.opportunity_id,
r.arr_amount amount
from {{ ref("fact_current_arr") }} r
join {{ ref("stg_opportunities_chain_of_renewals_v2") }} socr
on r.opportunity_id = socr.opportunity_id
)
,calculated as (
select
r.arr_type,
r.opportunity_id,
socr.parent_opportunities,
sum(r.arr_amount) amount
from {{ ref("fact_arr") }} r
join {{ ref("stg_opportunities_chain_of_renewals") }}    socr
on r.opportunity_id = socr.opportunity_id
where r.record_type='ARR'
and to_char(GetDate(),'yyyymm')::int = r.mon_year
and GetDate() between arr_activation_date and arr_deactivation_date
group by all
)
,sum_current as
(
select
arr_type,
sum(amount) amount
from current
group by arr_type
)
,sum_calculated as
(
select
arr_type,
sum(amount) amount
from calculated
group by arr_type
)
select
sum_current.arr_type,
sum_current.amount current_amount,
sum_calculated.amount calculated_amount,
sum_current.amount - sum_calculated.amount diff
from
sum_current
join
sum_calculated 
on sum_current.arr_type = sum_calculated.arr_type