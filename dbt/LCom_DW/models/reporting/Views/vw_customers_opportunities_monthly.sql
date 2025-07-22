{{ config(materialized='view',
   bind=False
)
 }}

select
a.sfdc_ultimate_parent_id,
fo.sfdc_account_id,
a.sfdc_name,
fo.opportunity_number ,
fo.name,
fo.opportunity_id,
fo.Stage_Name,
case when fo.created_date != '1900-01-01'::date then trunc(fo.created_date) end created_date,
case when fo.close_date != '1900-01-01'::date then fo.close_date end close_date,
case when fo.invoiced_date != '1900-01-01'::date then fo.invoiced_date end invoiced_date ,
case when fo.start_date != '1900-01-01'::date then fo.start_date end start_date,
case when fo.end_date != '1900-01-01'::date then fo.end_date end  end_date,
fo.opp_record_type,
fo.loss_reason,
fo.loss_notes,
s.mon_year,
s.record_type,
s.include_flg,
s.comments
from {{ ref("fact_opportunity") }} fo --change/add for opportunity history
join {{ ref("dim_account") }} a
on fo.account_id=a.account_id --change/add for account history
left outer join {{ ref("fact_customers_monthly_snapshots") }} s
on s.opportunity_id=fo.opportunity_id
and  ( s.record_type!='Starting' 
  or (s.record_type!='Starting' and s.mon_year like '%07'))