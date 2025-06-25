{{ config(
        
        materialized='incremental',
        unique_key='mon_year',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns',
        dist='sfdc_ultimate_parent_id',
        sort='mon_year'
)
 }}

with dim_month as --Thread to calculate monthly metrics
(select distinct c.mon_year, c.mon_firstday, c.mon_lastday from {{ source("common","dim_calendar") }} c 
where 
 
{{ month_range_to_load() }}

)
,final_data as 
(
--Not expired, current or future customers: Closed Won, invoiced, not enforced or expired no longer then 6 months ago (grace period)
--Current processing month is a "Starting" point for the next calendar month
--I do it for each month to have the ability re-start the calculation in each month
select distinct
 to_char(DATEADD( day, 1, mon.mon_lastday ),'yyyymm')::int as mon_year --next month starting point - 1 month shift forward
,LAST_DAY(DATEADD( day, 1, mon.mon_lastday ))  mon_lastday --next month starting point - 1 month shift forward
,o.opportunity_id
,a.sfdc_account_id
,a.sfdc_ultimate_parent_id
,'Starting' record_type
,true include_flg
,null as comments
from {{ ref("fact_opportunity") }} o
--
join {{ ref("dim_account") }} a
on o.account_id=a.account_id
join dim_month mon
on
case when o.license_unenforced then '3000-01-01'::date else o.End_Date end >= mon.mon_firstday  --still active this month  or expires in a future  or unenforced, need to start from first day to include not expired this month
and o.invoiced_date<=mon.mon_lastday --If it's invoiced AFTER start_date, there is a gap and it will be counted in the invoiced month
--
and o.invoiced_date !='1900-01-01' --invoiced
where o.account_id != '{{ var("default_ID") }}'
and a.sfdc_account_id!='{{ var("default_varchar") }}'
and Stage_name in ('Closed Won','Closed-Won Upsell')
and not (o.name ilike '%negative%' or
o.name ilike '%replacement%' or
o.name ilike '%Early Access%' or
o.name ilike '%LOI%')
and o.opp_record_type in ('New','Renewal','Upsell') --removing of the filter should not change the result Just for the sake of clarity, but there are Upsell without a new (0014100000tLECLAA4 - ultimate parent)
)
select
         mon_year::integer
	,mon_lastday::date
	,opportunity_id::varchar(300)
	,sfdc_account_id::varchar(300)
	,sfdc_ultimate_parent_id::varchar(300)
	,include_flg::boolean
	,record_type::varchar(20)        
	,comments::varchar(max)
        ,'{{ var("loaddate") }}'::timestamp as loaddate
from final_data