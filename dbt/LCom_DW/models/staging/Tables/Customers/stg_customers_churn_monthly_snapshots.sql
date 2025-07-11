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
,existing_ultimate_parent_customers as 
--to check if it's "alive" ultimate parent when only one child churned  (Closed Won invoiced opportunities from other child account and it is not in a moment to create renewal)
(select 
mon.mon_year,
case when a.sfdc_ultimate_parent_id='Unknown' then a.sfdc_account_id else a.sfdc_ultimate_parent_id end as sfdc_ultimate_parent_id,
max(case when license_unenforced then '3000-01-01'::date else o.End_Date end) latest_date
,listagg(distinct o.opportunity_id,',') existing_opportunities
from {{ ref("fact_opportunity") }} o
join {{ ref("dim_account") }} a
on o.account_id=a.account_id
join dim_month mon
on case when o.license_unenforced then '3000-01-01'::date else o.End_Date end > mon.mon_lastday --still active in next months, assuming if it's expired the processing month, renewal opportunity exist and current renewal ARR >0 
where
Stage_name in ('Closed Won','Closed-Won Upsell') --Closed Won can be new or renewal 
and o.invoiced_date !='1900-01-01' --invoiced date is not null
group by mon.mon_year,
case when a.sfdc_ultimate_parent_id='Unknown' then a.sfdc_account_id else a.sfdc_ultimate_parent_id end
)
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
,final_data 
as
(
-- the logic is based on SFDC Churn Report - https://learning.lightning.force.com/lightning/r/Report/00O1L000007R4G7UAK/view
-- for ultimate parent account: if a renewal child account opportunity is Closed Lost and Current Renewal Arr from All child accounts < 1 (meaning no other renewals in progress)
-- then ultimate parent account Churned
-- Current Renewal Arr is
-- True ARR from all child accounts opportunities where (Stage not equal to Closed Won, Closed Lost, Pilot in Progress, Pilot Successful, Pilot Unsuccessful) and (Opportunity Record Type equal Renewal)
-- What if there is Closed Won active opportunity from an other child account?
select distinct
 mon.mon_year
,mon.mon_lastday
,o.opportunity_id
,a.sfdc_account_id
,aup.sfdc_account_id as sfdc_ultimate_parent_id
--
,case 
  --no other child accounts have current renewal arr and no other child accounts have NOT expired opportunities
  when aup.SFDC_ultimate_parent_current_renewal_arr<1 and eupc.sfdc_ultimate_parent_id is null then 'Churn'
  when aup.SFDC_ultimate_parent_current_renewal_arr>1 or eupc.sfdc_ultimate_parent_id is not null then 'Not Churn'
  --when it was NOT included in the contract-based active customers at the start fiscal year or later        
  --it's still Churn but not included
end as record_type
--
,case 
when record_type='Churn' 
 and lpica.sfdc_ultimate_parent_id is not null   --it was counted as a customer in this fiscal year       
then True 
else False 
end  include_flg
--
,case 
 when aup.SFDC_ultimate_parent_current_renewal_arr>1 or eupc.sfdc_ultimate_parent_id is not null then
  case when eupc.sfdc_ultimate_parent_id is not null then 'Not expired opportunities: '+eupc.existing_opportunities else '' end 
  +
  case when aup.SFDC_ultimate_parent_current_renewal_arr>1 then 'Ultimate Parent Current Renewal ARR: '+aup.SFDC_ultimate_parent_current_renewal_arr::varchar else '' end 
 when lpica.sfdc_ultimate_parent_id is null then
  'It is not included in Churn monthly because it was not present in the contract-based active customers at the start fiscal year or later '
end as comments
--
from {{ ref("fact_opportunity") }} o
--original churn SFDC report uses Close or Churn date in the specific month (and close date in the fiscal year)
--this approach counts the same opportunity twice in different months if Close month <> Churn month
--Both dates can be changed manually at any time
--With any approach historical counts are changed
--I decided to use only Opportunity Close Date in processing month for Churn 
--assuming a Lost opportunity will be closed sooner or later and this should stop any changes in the opportunity
--if somebody set a previous month Churn date in closed opportunity few month later - we can not report churn historically
--if an opportunity is re-opened and then Churn and Close dates changed to earlier or more later - we can not report churn historically
join dim_month mon
on o.close_date between mon_firstday and mon_lastday 
--
join {{ ref("dim_account") }} a
on o.account_id=a.account_id
--we need current renewal arr for the ultimate parent
join {{ ref("dim_account") }} aup --is ultimate parent account
on case when a.sfdc_ultimate_parent_id='Unknown' then a.sfdc_account_id else a.sfdc_ultimate_parent_id end=aup.sfdc_account_id
--
--Was it included in the contract-based active customers at the start fiscal year or later If yes - include in Net Based Customers else exclude
left outer join last_present_in_contract_active lpica
on case when a.sfdc_ultimate_parent_id='Unknown' then a.sfdc_account_id else a.sfdc_ultimate_parent_id end=lpica.sfdc_ultimate_parent_id
and  to_date(lpica.mon_year::varchar+'01','yyyymmdd') >= mon.fiscalyear_startdate
--
--Are there  not expired Closed Won opportunities from other child accounts, not ready for renewal?
left outer join existing_ultimate_parent_customers eupc
on aup.sfdc_account_id = eupc.sfdc_ultimate_parent_id
and mon.mon_year = eupc.mon_year
--
where o.account_id != '{{ var("default_ID") }}'
and a.sfdc_account_id!='{{ var("default_varchar") }}'
and o.Stage_name in ('Closed Lost') 
and o.opp_record_type in ('Renewal')
and o.probability <10
and a.sfdc_current_renewal_arr<1 --no other renewals for this child account
--Test excluded in fact_opportunity
and a.sfdc_name not ilike '%Harmony%Public%Schools%'
and o.opportunity_number!='27760'
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