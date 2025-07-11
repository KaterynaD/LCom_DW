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
(select distinct c.mon_year, c.mon_firstday, c.mon_lastday, c.fiscalyear_startdate, c.fiscalyear_enddate from {{ source("common","dim_calendar") }} c 
where 

{{ month_range_to_load() }}

)
--
,latest as (
select --the most latest created opportunity per ultimate parent
case when a.sfdc_ultimate_parent_id='Unknown' then a.sfdc_account_id else a.sfdc_ultimate_parent_id end sfdc_ultimate_parent_id,
max(o.created_date) created_date
from {{ ref("fact_opportunity") }} o
join {{ ref("dim_account") }} a
on o.account_id=a.account_id
group by 
case when a.sfdc_ultimate_parent_id='Unknown' then a.sfdc_account_id else a.sfdc_ultimate_parent_id end)
--
, last_present_in_contract_active as (
  --when it was last counted as a customer in THIS FISCAL YEAR? 
  --(Last Month of a prev fiscal year is the first month of the current fiscal year stg_customers_contract_monthly_snapshots.mon_year)
  select 
  max(mon_year) mon_year,
  max(mon_lastday) mon_lastday,
  sfdc_ultimate_parent_id
  from {{ ref("stg_customers_contract_monthly_snapshots") }}

  group by sfdc_ultimate_parent_id
)
--
,churned_ultimate_parent_customers as  --to check if we churned this customer before Expiration on in 6 month 
(select  
 sfdc_ultimate_parent_id,
 mon.mon_year,
 max(c.mon_year) churned_mon_year,
 max(c.mon_lastday) churned_mon_lastday
from {{ ref("stg_customers_churn_monthly_snapshots") }} c
join dim_month mon
on c.mon_year <= mon.mon_year --churned before or in the currently processing month
where include_flg=true
and record_type='Churn'
group by mon.mon_year, sfdc_ultimate_parent_id
)
--
,final_data 
as
(
select --latest expired and no more new renewals were created after - a ghost customer
  distinct
  mon.mon_year
, mon.mon_lastday
,o.opportunity_id
,o.sfdc_account_id
,case when a.sfdc_ultimate_parent_id='Unknown' then a.sfdc_account_id else a.sfdc_ultimate_parent_id end as sfdc_ultimate_parent_id
--
,case 
 when lpica.sfdc_ultimate_parent_id is not null  
 and cupc.sfdc_ultimate_parent_id is  null 
 then 
 case 
 when o.disable_auto_renewal_opp 
  then 'NonRenewal' 
 else 'Ghost' 
 end
 else 'Unknown' 
 end record_type
--
 --if it included in the contract-based active customers at the start fiscal year or later
 --was not churned
,case 
 when lpica.sfdc_ultimate_parent_id is not null  
 and cupc.sfdc_ultimate_parent_id is  null 
 then True 
 else False 
 end  include_flg
--
,case  
 when lpica.sfdc_ultimate_parent_id is null then
  'It is not included in NonRenewal or Ghost monthly because it was not present in the contract-based active customers at the start fiscal year or later '
end as comments
from {{ ref("fact_opportunity") }} o
join {{ ref("dim_account") }} a
on o.account_id=a.account_id
--
join latest
on case when a.sfdc_ultimate_parent_id='Unknown' then a.sfdc_account_id else a.sfdc_ultimate_parent_id end = latest.sfdc_ultimate_parent_id
and o.created_date = latest.created_date
--
join dim_month mon
on   --expired 6 months ago and counted only once in the month when a 6-month grace period ended
to_char(date_add('month', 6, o.end_date),'yyyymm') = mon.mon_year
and o.end_date !='1900-01-01' --has explicit expiration date
and license_unenforced=false --expiration is enforced
--
--Was it included in the contract-based active customers in this fiscal year?
left outer join last_present_in_contract_active lpica
on case when a.sfdc_ultimate_parent_id='Unknown' then a.sfdc_account_id else a.sfdc_ultimate_parent_id end=lpica.sfdc_ultimate_parent_id
and  to_date(lpica.mon_year::varchar+'01','yyyymmdd') >= mon.fiscalyear_startdate
--
--Was it churned before expiration or in 6 month grace period?
left outer join churned_ultimate_parent_customers cupc
on case when a.sfdc_ultimate_parent_id='Unknown' then a.sfdc_account_id else a.sfdc_ultimate_parent_id end=cupc.sfdc_ultimate_parent_id
and mon.mon_year = cupc.mon_year --cupc.mon_year DOES contain the current month
--
where invoiced_date !='1900-01-01' --invoiced date is not null
and Stage_name in ('Closed Won','Closed-Won Upsell')
and not (name ilike '%negative%' or
name ilike '%replacement%' or
name ilike '%Early Access%' or
name ilike '%LOI%')
and o.opp_record_type in ('New','Upsell')
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