{{
    config(

        materialized='table',        
        dist='opportunity_id' 
        
        )
}}

with base_data as 
/*3 ARR types need identical data except start,end,activate and deactivate dates*/
(
    select 'True' ARR_Type, * from {{ ref("stg_arr_base") }}
    union all
    select 'Preliminary' ARR_Type, * from {{ ref("stg_arr_base") }}
    union all
    select 'Backdated' ARR_Type, * from {{ ref("stg_arr_base") }}
)
/*extended rawdata to all what's needed for ARR step 1*/
, ARR_Data_base as (
select distinct
d.ARR_Type,
d.HasParent,
fo.opportunity_id,
fo.stage_name,
fo.account_id,
a.sfdc_billing_state_code state_code,
fo.invoiced_date ,
fo.close_date,
case 
 when d.ARR_Type!='Backdated' then
  greatest(case when fo.stage_name ilike '%won%' then fo.invoiced_date else fo.close_date end, fo.start_date) 
 else /*In Backdated ARR the shift related to invoiced_date and close_date is applied in Activateion Date*/
  fo.start_date
end as start_date,
fo.start_date start_date_sfdc,
fo.end_date,
fo.renewal_opportunity_id,
fro.stage_name renewal_stage_name,
fro.invoiced_date renewal_invoiced_date,
fro.close_date renewal_close_date,
case 
 when d.ARR_Type!='Backdated' then
  greatest(case when fro.stage_name ilike '%won%' then fro.invoiced_date else fro.close_date end, fro.start_date)
 else 
  fro.start_date
end as renewal_start_date,
fro.start_date renewal_start_date_sfdc,
fro.end_date renewal_end_date,
d.sfdc_product_id ,
d.bucket ,
d.total_price ,
d.parent_total_price ,
d.max_parent_end_date
from base_data d
join {{ ref("fact_opportunity") }} fo
on fo.opportunity_id=d.opportunity_id
left outer join (select fro.* from {{ ref("fact_opportunity") }} fro join {{ ref("stg_valid_opportunities") }} ooi on fro.opportunity_id = ooi.opportunity_id) as fro
on fro.opportunity_id=fo.renewal_opportunity_id
join {{ ref("dim_sfdc_product") }} dsp
on d.sfdc_product_id = dsp.sfdc_product_id
join {{ ref("dim_account") }} a
on a.account_id = fo.account_id
/*assuming renewal is for the same account as a parent. It is not true, but at least they should be in teh same state*/
where dsp.sfdc_product_name not ilike '%wire transfer%'
and not(fo.name ilike '%NEGATIVE OPP%' or fo.name ilike '%REPLACEMENT OPP%')
)
/*extended rawdata to all what's needed for ARR step 2*/
, ARR_Data as (
select distinct
ARR_Type,
HasParent,
opportunity_id,
stage_name,
account_id,
invoiced_date ,
close_date,
greatest(dateadd(day,1,max_parent_end_date), case when start_date!='1900-01-01' then start_date else dateadd(day,1,max_parent_end_date) end) as start_date,
start_date_sfdc,
case

/*Only Preliminary ARR needs adjusted to the grace period End Date*/
 when ARR_Type='Preliminary' then 

 least(
  case
   when renewal_stage_name in ( 'Closed Won', 'Closed-Won Upsell') and renewal_invoiced_date!='1900-01-01' then greatest(dateadd(day, -1,renewal_invoiced_date),end_date)
   when renewal_stage_name in ( 'Closed Lost') then greatest(dateadd(day, -1,renewal_close_date),end_date)
   else '3000-01-01'::date
  end,
  case
   when bucket ilike '%biz_dev%' then dateadd(month, 6, end_date) --Biz Dav are not expired does not work because we have "active" Biz Dev without renewals since 2019
   when state_code = 'TX' then dateadd(day, 90, end_date) --Texas all account plus 90 days grace period
   else dateadd(day, 60, end_date) --All other states 60 days grace period
  end
      ) 

 else end_date

end as end_date,
end_date as end_date_sfdc,

case

/*Only Backdated ARR needs Activateion Date*/
 when ARR_Type='Backdated' then 
  case
   when stage_name in ( 'Closed Won', 'Closed-Won Upsell') and invoiced_date!='1900-01-01' then invoiced_date
   when stage_name in ( 'Closed Lost') then close_date
   else '1900-01-01'::date
  end 

  else '1900-01-01'::date
  
end as arr_activation_date,
renewal_opportunity_id,
renewal_stage_name,
renewal_invoiced_date,
renewal_close_date,
case when renewal_start_date!='1900-01-01'::date then renewal_start_date else dateadd(day,1,end_date) end renewal_start_date,
renewal_start_date_sfdc,
renewal_end_date,
sfdc_product_id ,
bucket ,
total_price ,
parent_total_price ,
case

/*Only Preliminary ARR needs adjusted to the grace period Max Parent End Date*/
 when ARR_Type='Preliminary' then 
  least(
   case
     when stage_name in ( 'Closed Won', 'Closed-Won Upsell') and invoiced_date!='1900-01-01' then greatest(dateadd(day, -1,invoiced_date),max_parent_end_date)
     when stage_name in ( 'Closed Lost') then greatest(dateadd(day, -1,close_date),max_parent_end_date)
    else '3000-01-01'::date
   end ,
   case
    when bucket ilike '%biz_dev%' then dateadd(month, 6, max_parent_end_date)  --Biz Dav are not expired does not work because we have "active" Biz Dev without renewals since 2019
    when state_code = 'TX' then dateadd(day, 90, max_parent_end_date) --Texas all account plus 90 days grace period
    else dateadd(day, 60, max_parent_end_date) --All other states 60 days grace period
   end
      )

 else max_parent_end_date

end as max_parent_end_date,
max_parent_end_date as max_parent_end_date_sfdc
from ARR_Data_base fb
)
/*fiscal calendar data*/
, arr_data_extended as
(
select
d.ARR_Type,
cal.mon_year,
cal.mon_lastday,
cal.fiscalyear,
cal.fiscalyear_mon,
d.HasParent,
d.opportunity_id,
d.stage_name,
d.account_id,
d.invoiced_date ,
d.close_date,
d.start_date,
d.start_date_sfdc,
d.end_date,
d.end_date_sfdc,
d.arr_activation_date,
d.renewal_opportunity_id,
d.renewal_stage_name,
d.renewal_invoiced_date,
d.renewal_close_date,
d.renewal_start_date,
d.renewal_start_date_sfdc,
d.renewal_end_date,
d.sfdc_product_id ,
d.bucket ,
d.total_price ,
d.parent_total_price,
d.max_parent_end_date,
d.max_parent_end_date_sfdc
from ARR_data d
join {{ ref("dim_month") }} cal
on start_date between cal.mon_firstday and cal.mon_lastday
)
/*New and Renewal data exist in Opportunity Product Line "as is"*/
, New_Renewal_data as
(
select
ARR_Type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
HasParent,
opportunity_id,
stage_name,
account_id,
invoiced_date ,
close_date,
start_date,
start_date_sfdc,
end_date,
end_date_sfdc,
arr_activation_date,
renewal_opportunity_id,
renewal_stage_name,
renewal_invoiced_date,
renewal_close_date,
renewal_start_date,
renewal_start_date_sfdc,
renewal_end_date,
sfdc_product_id ,
Bucket,
total_price ,
parent_total_price ,
max_parent_end_date,
max_parent_end_date_sfdc
from ARR_Data_extended
where stage_name != 'Closed Lost'
and total_price is not null --we may have these lines from full outer join They are important for PI and Downsell or Cancellations 
)
/*Price Increase and Downsell are calculated from true Won renewals in Tableau or later in downstream views. It's a place holder for downstream calculation in Tableau. Can be 0 for some combinations*/
, placeholder_data as
(
select
ARR_Type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
HasParent,
opportunity_id,
stage_name,
account_id,
invoiced_date ,
close_date,
start_date,
start_date_sfdc,
end_date,
end_date_sfdc,
arr_activation_date,
renewal_opportunity_id,
renewal_stage_name,
renewal_invoiced_date,
renewal_close_date,
renewal_start_date,
renewal_start_date_sfdc,
renewal_end_date,
sfdc_product_id ,
'Sales : Placeholder for Price Increase or Downsell : ' +case when bucket ilike '%biz_dev%' then 'Biz Dev' else 'ARR' end as Bucket,
sum(case when bucket ilike '%new%' then total_price else 0 end) as total_price, --only "renewal" price (renew or new) Won buckets to calculate PI or Downsell. Upsell in renewal is ignored
sum(parent_total_price) as parent_total_price, --all parent price should be caunted for renewal
max(max_parent_end_date) as max_parent_end_date, --latest parent expiration date
max(max_parent_end_date_sfdc) as max_parent_end_date_sfdc --latest parent expiration date original
from ARR_Data_extended
where hasparent = True
and stage_name != 'Closed Lost'
group by all
)
/*Cancellation amount is calculated from true Closed Lost renewals. It's a place holder for downstream calculation in Tableau. Can be 0 for some combinations*/
, Cancellation_data as
(
select
ARR_Type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
HasParent,
opportunity_id,
stage_name,
account_id,
invoiced_date ,
close_date,
start_date,
start_date_sfdc,
end_date,
end_date_sfdc,
arr_activation_date,
renewal_opportunity_id,
renewal_stage_name,
renewal_invoiced_date,
renewal_close_date,
renewal_start_date,
renewal_start_date_sfdc,
renewal_end_date,
sfdc_product_id ,
'Sales : Cancellation : ' +case when bucket ilike '%biz_dev%' then 'Biz Dev' else 'ARR' end as Bucket,
null::float total_price , --we need only parent ARR to cancel
sum(parent_total_price) as parent_total_price,
max(max_parent_end_date) as max_parent_end_date,
max(max_parent_end_date_sfdc) as max_parent_end_date_sfdc
from ARR_Data_extended
where hasparent = True
and stage_name = 'Closed Lost'
and isnull(parent_total_price,0)!=0
group by all
)
,data as (
select
ARR_Type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
HasParent,
opportunity_id,
stage_name,
account_id,
invoiced_date ,
close_date,
start_date,
start_date_sfdc,
end_date,
end_date_sfdc,
arr_activation_date,
renewal_opportunity_id,
renewal_stage_name,
renewal_invoiced_date,
renewal_close_date,
renewal_start_date,
renewal_start_date_sfdc,
renewal_end_date,
sfdc_product_id ,
Bucket,
total_price ,
parent_total_price ,
max_parent_end_date ,
max_parent_end_date_sfdc
from New_Renewal_data
union all
select
ARR_Type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
HasParent,
opportunity_id,
stage_name,
account_id,
invoiced_date ,
close_date,
start_date,
start_date_sfdc,
end_date,
end_date_sfdc,
arr_activation_date,
renewal_opportunity_id,
renewal_stage_name,
renewal_invoiced_date,
renewal_close_date,
renewal_start_date,
renewal_start_date_sfdc,
renewal_end_date,
sfdc_product_id ,
Bucket,
total_price ,
parent_total_price ,
max_parent_end_date ,
max_parent_end_date_sfdc
from Placeholder_data
union all
select
ARR_Type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
HasParent,
opportunity_id,
stage_name,
account_id,
invoiced_date ,
close_date,
start_date,
start_date_sfdc,
end_date,
end_date_sfdc,
arr_activation_date,
renewal_opportunity_id,
renewal_stage_name,
renewal_invoiced_date,
renewal_close_date,
renewal_start_date,
renewal_start_date_sfdc,
renewal_end_date,
sfdc_product_id ,
Bucket,
total_price ,
parent_total_price ,
max_parent_end_date ,
max_parent_end_date_sfdc
from Cancellation_data
)
select
ARR_Type::varchar(20),
mon_year::integer,
mon_lastday::date,
fiscalyear::varchar(20),
fiscalyear_mon::integer,
HasParent::boolean,
opportunity_id::varchar(300),
stage_name::varchar(780),
account_id::varchar(300),
invoiced_date::date ,
close_date::date,
start_date::date,
start_date_sfdc::date,
end_date::date,
end_date_sfdc::date,
arr_activation_date::date,
renewal_opportunity_id::varchar(300),
isnull(renewal_stage_name,'Unknown')::varchar(780) as renewal_stage_name,
isnull(renewal_invoiced_date,'1900-01-01'::date) as renewal_invoiced_date,
isnull(renewal_close_date,'1900-01-01'::date) as renewal_close_date,
isnull(renewal_start_date,'1900-01-01'::date) as renewal_start_date,
isnull(renewal_start_date_sfdc,'1900-01-01'::date) as renewal_start_date_sfdc,
isnull(renewal_end_date,'1900-01-01'::date) as renewal_end_date,
sfdc_product_id::varchar(300) ,
Bucket::varchar(100),
isnull(total_price,0)::numeric(38,10) as total_price ,
isnull(parent_total_price,0)::numeric(38,10) as parent_total_price,
isnull(max_parent_end_date::date,'1900-01-01'::date) as max_parent_end_date,
isnull(max_parent_end_date_sfdc::date,'1900-01-01'::date) as max_parent_end_date_sfdc
from data
where mon_year!=0
