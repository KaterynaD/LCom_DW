{{
    config(

        materialized='table',        
        dist='opportunity_id' 
        
        )
}}

select
arr_type::varchar(20),
to_char(GetDate(),'yyyymm')::int mon_year,
o.account_id :: varchar(300),
r.opportunity_id :: varchar(300),
sum(r.total_price)::numeric(38,10) as arr_amount,
'{{ var("loaddate") }}'::timestamp as loaddate
from {{ ref('int_arr_base') }} r
join {{ ref('fact_opportunity') }} o
on r.opportunity_id = o.opportunity_id
--current month start and end dates
join {{ ref('dim_calendar') }} d
on trunc(GetDate()) = d.cal_date
where
--Won, invoiced opportunities active Today
trunc(GetDate()) between r.start_date and r.end_date
and r.stage_name ilike '%won%'
and r.invoiced_date!='1900-01-01'
and r.invoiced_date <= GetDate()
and r.bucket in (
'Sales : New Business : ARR',
'Sales : New Business : Biz Dev',
'Sales : Renewal : ARR',
'Sales : Renewal : Biz Dev',
'Sales : Upsell : ARR',
'Sales : Upsell : Biz Dev',
'Sales : Reseller ARR Renewal',
'Sales : Reseller ARR Upsell')
group by all