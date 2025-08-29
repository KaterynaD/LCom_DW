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
(select distinct c.mon_year, c.mon_firstday, c.mon_lastday, c.fiscalyear_startdate from {{ source("common","dim_calendar") }} c 
where 

{{ month_range_to_load() }}

)
--
,existing_ultimate_parent_customers as --to check if it's a new ultimate parent customer or existing (Closed Won invoiced opportunities from other childs accounts)
(select 
mon.mon_year,
a.sfdc_ultimate_parent_id,
max(o.invoiced_date) latest_invoiced_date,
max(case when o.license_unenforced and (ro.opportunity_id is null or not(ro.close_date<=mon.mon_lastday and ro.stage_name='Closed Lost')) /*no Closed Lost renewals in this month or before*/
then '3000-01-01'::date else o.End_Date end) latest_date
,listagg(distinct o.opportunity_id,',') existing_opportunities
from {{ ref("fact_opportunity") }} o
join {{ ref("dim_account") }} a
on o.account_id=a.account_id
join dim_month mon
on o.invoiced_date < mon.mon_firstday --invoiced before the currently processing  month in any fiscal year!!!
and o.invoiced_date !='1900-01-01' --invoiced date is not null
left outer join {{ ref("fact_opportunity") }} ro
on o.renewal_opportunity_id = ro.opportunity_id
where 
o.Stage_name in ('Closed Won','Closed-Won Upsell') 
and not (o.name ilike '%negative%' or
o.name ilike '%replacement%' or
o.name ilike '%Early Access%' or
o.name ilike '%LOI%')
and o.opp_record_type in ('New','Renewal','Upsell')
group by mon.mon_year,
a.sfdc_ultimate_parent_id)
--
,churned_ultimate_parent_customers as  --to check if we recently churned this customer and need return it back as new/Returning
(select  
 sfdc_ultimate_parent_id,
 mon.mon_year,
 max(c.mon_year) churned_mon_year,
 max(c.mon_lastday) churned_mon_lastday
from {{ ref("stg_customers_churn_monthly_snapshots") }} c
join dim_month mon
on c.mon_lastday < mon.mon_firstday --churned before the currently processing  month!!!
and c.mon_lastday>=mon.fiscalyear_startdate --churned in the current fiscal year
where include_flg=true
and record_type='Churn'
group by mon.mon_year, sfdc_ultimate_parent_id
)
--
,nonrenewal_ultimate_parent_customers as  --to check if we recently churned this customer and need return it back as new/Returning
(select  
 sfdc_ultimate_parent_id,
 mon.mon_year,
 max(c.mon_year) nonrenewal_mon_year,
 max(c.mon_lastday) nonrenewal_mon_lastday
from {{ ref("stg_customers_nonrenewal_monthly_snapshots") }} c
join dim_month mon
on c.mon_lastday < mon.mon_firstday --nonrenewed before the currently processing  month!!!
and c.mon_lastday>=mon.fiscalyear_startdate --nonrenewed in the current fiscal year
where include_flg=true
group by mon.mon_year, sfdc_ultimate_parent_id
)
--
,final_data 
as
(
select distinct
  mon.mon_year
, mon.mon_lastday
,o.opportunity_id
,a.sfdc_account_id
,case when a.sfdc_ultimate_parent_id='Unknown' then a.sfdc_account_id else a.sfdc_ultimate_parent_id end as sfdc_ultimate_parent_id
--
,case 
 when aupc.sfdc_ultimate_parent_id is null then 'New' --no records in existing_ultimate_parent_customers
 else --ultimate parent in existing_ultimate_parent_customers
  case

   --Exp Before  1st day Last Month Prev Fiscal Year -> NOT counted in Last Month Prev Fiscal year -> new/renewal any month new fiscal year -> Returning
     when aupc.latest_date  < date_add('month', -1, mon.fiscalyear_startdate) 
     then 'Returning' 

   --Exp After or on 1st day Last Month Prev Fiscal Year -> counted in Last Month Prev Fiscal year  -> new/renewal consequent month (no gap and no churn, no non renewal before new/renewal invoice date) -> Existing
     when aupc.latest_date  >= date_add('month', -1, mon.fiscalyear_startdate) 
     and  LAST_DAY(aupc.latest_date)  =  date_add('month', -1, mon.mon_lastday) --NO gaps between expiration and new/renewal invoice
     and  cupc.churned_mon_lastday is null --NO CHURN before new/renewal invoice date in this fiscal year
     and  nupc.nonrenewal_mon_lastday is null --NO NON RENEWAL or GHOST before new/renewal invoice date in this fiscal year
     then 'Existing'

 
   --Exp After or on 1st day Last Month Prev Fiscal Year -> counted in Last Month Prev Fiscal year  -> new/renewal with a gap at least 1 month AND a churn before new/renewal invoice date -> Returning  
     when aupc.latest_date  >= date_add('month', -1, mon.fiscalyear_startdate) 
     and  LAST_DAY(aupc.latest_date)  <  date_add('month', -1, mon.mon_lastday) --GAP between expiration and new/renewal invoice
     and  (
          cupc.churned_mon_lastday is NOT NULL  --CHURN before new/renewal invoice date in this fiscal year
    or    nupc.nonrenewal_mon_lastday is NOT NULL --NON RENEWAL or GHOST before new/renewal invoice date in this fiscal year
          )
     then 'ReturningFY' 

     else 'Existing'
   
    end

 end as record_type
 --
,case
  when record_type in ('New','Returning','ReturningFY') then true
  else false
 end as  include_flg

,case 
 when aupc.sfdc_ultimate_parent_id is not null or cupc.churned_mon_lastday is not null or nupc.nonrenewal_mon_lastday is not null then 
  case when cupc.churned_mon_lastday is not null then 'Churned: '+to_char(cupc.churned_mon_lastday,'yyyy-mm-dd') else '' end 
  + 
  case when nupc.nonrenewal_mon_lastday is not null then 'NonRenewed or Ghost: '+to_char(nupc.nonrenewal_mon_lastday,'yyyy-mm-dd') else '' end 
  + 
  case when aupc.sfdc_ultimate_parent_id is not null then 
  'Latest previous invoice date: '+to_char(aupc.latest_invoiced_date,'yyyy-mm-dd')+
  ' ,Latest Expiration (End) Date: '+case when aupc.latest_date='3000-01-01'::date then 'License Unenforced' when aupc.latest_date='1900-01-01'::date then 'Unknown' else to_char(aupc.latest_date,'yyyy-mm-dd') end 
  +' ,Opportunities: '+aupc.existing_opportunities
  else ''
  end
end
as comments
from {{ ref("fact_opportunity") }} o
join {{ ref("dim_account") }} a
on o.account_id=a.account_id
join dim_month mon
on o.invoiced_date between mon.mon_firstday and mon.mon_lastday
--Is it's an existing or new ultimate parent account? Need to check existing oppotunities before the current month
left outer join existing_ultimate_parent_customers as aupc 
on case when a.sfdc_ultimate_parent_id='Unknown' then a.sfdc_account_id else a.sfdc_ultimate_parent_id end = aupc.sfdc_ultimate_parent_id 
and mon.mon_year = aupc.mon_year --aupc.mon_year does not contain the current month
--Churned accounts should be counted back
left outer join churned_ultimate_parent_customers cupc
on case when a.sfdc_ultimate_parent_id='Unknown' then a.sfdc_account_id else a.sfdc_ultimate_parent_id end = cupc.sfdc_ultimate_parent_id 
and mon.mon_year = cupc.mon_year --cupc.mon_year does not contain the current month
--Nonrenewed accounts should be counted back
left outer join nonrenewal_ultimate_parent_customers nupc
on case when a.sfdc_ultimate_parent_id='Unknown' then a.sfdc_account_id else a.sfdc_ultimate_parent_id end = nupc.sfdc_ultimate_parent_id 
and mon.mon_year = nupc.mon_year --nupc.mon_year does not contain the current month
--
where o.account_id != '{{ var("default_ID") }}'
and a.sfdc_account_id!='{{ var("default_varchar") }}'
and Stage_name in ('Closed Won','Closed-Won Upsell') 
and not (o.name ilike '%negative%' or
o.name ilike '%replacement%' or
o.name ilike '%Early Access%' or
o.name ilike '%LOI%')
and o.opp_record_type in ('New','Upsell','Renewal')
--Test excluded in fact_opportunity
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