{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select 
m.mon_year,
m.mon_lastday,
m.fiscalyear,
m.fiscalyear_mon,
i.category,
listagg(i.issue, ', ') within group (order by i.issue) as issue,
o.opportunity_id,
o.opportunity_number,
o.name as opportunity_name,
o.stage_name,
case when o.invoiced_date='1900-01-01' then null else o.invoiced_date end as invoiced_date,
o.close_date,
o.start_date,
case when o.end_date in ('3000-01-01','1900-01-01') then null else o.end_date end as end_date,
o.arr,
da.account_id,
da.sfdc_account_id,
da.sfdc_name as account_name
from {{ ref('fact_opportunity') }} o
join {{ ref('dim_arr_audit') }} a
on o.opportunity_id = a.opportunity_id
join {{ ref('dim_arr_issue') }} i
on a.issue_id = i.issue_id
join {{ ref('dim_month') }} m
on m.mon_year = a.mon_year
join {{ ref('dim_account') }} da
on da.account_id = o.account_id
group by all