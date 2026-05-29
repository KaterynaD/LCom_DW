{{ config(
        
        materialized='incremental',
        unique_key='mon_year',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns',
        dist='even',
        sort='mon_year'
)
 }}

 with  dim_month as --Thread to calculate monthly metrics 
(
select 
* 
from {{ ref('dim_month') }}
where  {{ month_range_to_load() }}
)
,starting_data as (
--Based on Active Closed-Won opportunities at the end of the month
select
'Contract Active'::varchar record_type,
mon.mon_year,
mon.mon_lastday,
mon.fiscalyear,
mon.fiscalyear_mon,
fb.opportunity_id,
fb.sfdc_account_id,
fb.sfdc_ultimate_parent_id,
fb.amount
from {{ ref('stg_revenue') }} fb
join  dim_month mon
on
case when fb.license_unenforced  then '3000-01-01'::date else fb.End_Date end >= mon.mon_firstday --still active this month or expires in a future or unenforced, need to start from first day to include not expired this month 
and fb.invoiced_date<=mon.mon_lastday --If it's invoiced AFTER start_date, there is a gap and it will be counted in the invoiced month 
where (fb.renewal_invoiced_date='1900-01-01' or fb.renewal_invoiced_date>mon.mon_lastday)--no invoiced renewals yet in this month
and not(fb.renewal_close_date<=mon.mon_lastday and fb.renewal_stage_name='Closed Lost') --no Closed Lost renewals in this month or before
and fb.bucket in (
'Sales : New Business : ARR',
'Sales : New Business : Biz Dev',
'Sales : Renewal : ARR',
'Sales : Renewal : Biz Dev',
'Sales : Upsell : ARR',
'Sales : Upsell : Biz Dev',
'Sales : Reseller ARR Renewal',
'Sales : Reseller ARR Upsell'
)
and (fb.disable_auto_renewal_opp=false or fb.renewal_opportunity_id!='Unknown')
)
select
record_type::varchar(20),
mon_year::integer,
mon_lastday::date,
fiscalyear::varchar(20),
fiscalyear_mon::integer,
opportunity_id::varchar(300),
sfdc_account_id::varchar(300),
sfdc_ultimate_parent_id::varchar(300),
amount::float,
'{{ var("loaddate") }}'::timestamp AS loaddate
from starting_data