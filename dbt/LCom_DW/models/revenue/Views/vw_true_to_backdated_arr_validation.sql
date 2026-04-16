{{ config(
    materialized = 'view',
    bind = false
) }}

with Backdated_arr as (
select 
mon_year,
sum(case when mon_lastday between arr_activation_date and arr_deactivation_date then arr_amount else 0 end) backdated_arr_amount
from {{ ref("fact_arr") }}
where arr_type='Backdated'
and record_type='ARR'
group by mon_year
)
,true_arr as (
select 
mon_year,
sum(arr_amount) true_arr_amount
from {{ ref("fact_arr") }}
where arr_type='True'
and record_type='ARR'
and GetDate() between arr_activation_date and arr_deactivation_date
group by mon_year
)
select
ta.mon_year,
true_arr_amount,
backdated_arr_amount,
true_arr_amount - backdated_arr_amount diff,
100*abs(true_arr_amount - backdated_arr_amount)/nullif(true_arr_amount,0)::float pct_diff
from true_arr ta
join backdated_arr ba
on ta.mon_year = ba.mon_year
