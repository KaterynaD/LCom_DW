{{ config(materialized='view',
   bind=False
)
 }}

select 
v.known_issue,
v.known_issue_description,
v.Arr_type,
v.validation_issue,
o.opportunity_id,
o.opportunity_number,
o.name as opportunity_name,
o.stage_name,
case when o.invoiced_date='1900-01-01' then null else o.invoiced_date end as invoiced_date,
o.close_date,
o.start_date,
case when o.end_date in ('3000-01-01','1900-01-01') then null else o.end_date end as end_date,
da.account_id,
da.sfdc_account_id,
da.sfdc_name as account_name,
v.current_amount, 
v.calculated_amount,
v.diff
from {{ ref('fact_opportunity') }} o
join {{ ref('dim_arr_validation') }} v
on o.opportunity_id = v.opportunity_id
join {{ ref('dim_account') }} da
on da.account_id = o.account_id