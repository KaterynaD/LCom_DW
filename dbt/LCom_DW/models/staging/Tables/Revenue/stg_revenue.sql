{{ config(
        
        materialized='incremental',
        unique_key='mon_year',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns',
        dist='opportunity_id',
        sort='mon_year'
)
 }}

with cal as (select distinct			
c.mon_year, c.mon_firstday, c.mon_lastday,c.fiscalyear, c.fiscalyear_mon			
from {{ source("common","dim_calendar") }} c			
where 

{{ month_range_to_load() }}		

)
, ARR_rawdata as (			
select			
cal.mon_year,			
cal.mon_lastday,			
cal.fiscalyear,			
cal.fiscalyear_mon,			
fo.opportunity_id,			
fo.stage_name,			
fo.opp_record_type ,				
a.sfdc_account_id,			
a.sfdc_state_initiative,					
a.sfdc_ultimate_parent_id,			
fo.invoiced_date ,			
fo.close_date,			
fo.start_date,			
fo.end_date,			
fo.renewal_opportunity_id,			
fro.stage_name renewal_stage_name,			
fro.invoiced_date renewal_invoiced_date,			
fro.close_date renewal_close_date,			
fo.disable_auto_renewal_opp,			
fo.license_unenforced,			
dol.opportunity_line_id ,			
dol.class ,			
dol.total_price			
from {{ ref('dim_opportunity_line') }} dol			
join {{ ref('fact_opportunity') }} fo			
on fo.opportunity_id=dol.opportunity_id			
left outer join {{ ref('fact_opportunity') }} fro			
on fro.opportunity_id=fo.renewal_opportunity_id			
join {{ ref('dim_sfdc_product') }} dsp			
on dol.sfdc_product_id = dsp.sfdc_product_id			
join {{ ref('dim_account') }} a			
on fo.account_id=a.account_id			
join cal			
on fo.invoiced_date between cal.mon_firstday and cal.mon_lastday			
where dsp.sfdc_product_name not ilike '%wire transfer%'			
and fo.stage_name in ( 'Closed Won', 'Closed-Won Upsell')			
)			
,ARR_data as			
(			
select			
mon_year,			
mon_lastday,			
fiscalyear,			
fiscalyear_mon,			
opportunity_id,				
stage_name,			
opp_record_type ,					
sfdc_account_id,			
sfdc_state_initiative,						
sfdc_ultimate_parent_id,			
invoiced_date ,			
close_date,			
start_date,			
end_date,			
renewal_opportunity_id,			
renewal_stage_name,			
renewal_invoiced_date,			
renewal_close_date,			
disable_auto_renewal_opp,			
license_unenforced,			
class as bucket,			
sum(total_price) as amount			
from ARR_rawdata			
group by			
mon_year,			
mon_lastday,			
fiscalyear,			
fiscalyear_mon,			
opportunity_id,				
stage_name,			
opp_record_type ,			
sfdc_account_id,				
sfdc_state_initiative,				
sfdc_ultimate_parent_id,			
invoiced_date ,			
close_date,			
start_date,			
end_date,			
renewal_opportunity_id,			
renewal_stage_name,			
renewal_invoiced_date,			
renewal_close_date,			
disable_auto_renewal_opp,			
license_unenforced,			
class			
)			
, Price_Increase_data as			
(			
select			
cal.mon_year,			
cal.mon_lastday,			
cal.fiscalyear,			
cal.fiscalyear_mon,			
fo.opportunity_id,					
fo.stage_name,			
fo.opp_record_type ,			
a.sfdc_account_id,			
a.sfdc_state_initiative,			
a.sfdc_ultimate_parent_id,			
fo.invoiced_date ,			
fo.close_date,			
fo.start_date,			
fo.end_date,			
fo.renewal_opportunity_id,			
fro.stage_name renewal_stage_name,			
fro.invoiced_date renewal_invoiced_date,			
fro.close_date renewal_close_date,			
fo.disable_auto_renewal_opp,			
fo.license_unenforced,			
'Sales' +' : '+ 'Price Increased' + ' : ' +case when a.sfdc_state_initiative then 'Biz Dev'else 'ARR' end as Bucket,			
fo.price_increase_arr as amount			
from {{ ref('fact_opportunity') }} fo			
left outer join {{ ref('fact_opportunity') }} fro			
on fro.opportunity_id=fo.renewal_opportunity_id			
join {{ ref('dim_account') }} a			
on fo.account_id=a.account_id			
join cal			
on fo.invoiced_date between cal.mon_firstday and cal.mon_lastday			
where fo.stage_name in ( 'Closed Won', 'Closed-Won Upsell')			
and fo.price_increase_arr>0			
)			
,reduction_data as (			
select			
cal.mon_year,			
cal.mon_lastday,			
cal.fiscalyear,			
cal.fiscalyear_mon,			
fo.opportunity_id,					
fo.stage_name,			
fo.opp_record_type ,				
a.sfdc_account_id,			
a.sfdc_state_initiative,					
a.sfdc_ultimate_parent_id,			
fo.invoiced_date ,			
fo.close_date,			
fo.start_date,			
fo.end_date,			
fo.renewal_opportunity_id,			
fro.stage_name renewal_stage_name,			
fro.invoiced_date renewal_invoiced_date,			
fro.close_date renewal_close_date,			
fo.disable_auto_renewal_opp,			
fo.license_unenforced,			
'Sales' +' : '+ 'Reduction' + ' : ' +case when a.sfdc_state_initiative then 'Biz Dev'else 'ARR' end as Bucket,			
case when fo.stage_name in ( 'Closed Won', 'Closed-Won Upsell') then fo.downsell else 0 end as amount			
from {{ ref('fact_opportunity') }} fo			
left outer join {{ ref('fact_opportunity') }} fro			
on fro.opportunity_id=fo.renewal_opportunity_id			
join {{ ref('dim_account') }} a			
on fo.account_id=a.account_id			
join cal			
on fo.invoiced_date between cal.mon_firstday and cal.mon_lastday			
where fo.stage_name in ( 'Closed Won', 'Closed-Won Upsell')			
and fo.opp_record_type='Renewal'	
and not(fo.name ilike '%NEGATIVE OPP%' or fo.name ilike '%REPLACEMENT OPP%')	
and fo.downsell!=0			
)			
,cancellation_data as (			
select			
cal.mon_year,			
cal.mon_lastday,			
cal.fiscalyear,			
cal.fiscalyear_mon,			
fo.opportunity_id,					
fo.stage_name,			
fo.opp_record_type ,			
a.sfdc_account_id,			
a.sfdc_state_initiative,					
a.sfdc_ultimate_parent_id,			
fo.invoiced_date ,			
fo.close_date,			
fo.start_date,			
fo.end_date,			
fo.renewal_opportunity_id,			
fro.stage_name renewal_stage_name,			
fro.invoiced_date renewal_invoiced_date,			
fro.close_date renewal_close_date,			
fo.disable_auto_renewal_opp,			
fo.license_unenforced,			
'Sales' +' : '+ 'Cancellation' + ' : ' +case when a.sfdc_state_initiative then 'Biz Dev'else 'ARR' end as Bucket,			
-fo.true_arr_formula as amount			
from {{ ref('fact_opportunity') }} fo			
left outer join {{ ref('fact_opportunity') }} fro			
on fro.opportunity_id=fo.renewal_opportunity_id			
join {{ ref('dim_account') }} a			
on fo.account_id=a.account_id			
join cal			
on fo.close_date between cal.mon_firstday and cal.mon_lastday			
where fo.stage_name = 'Closed Lost'			
and fo.opp_record_type='Renewal'			
)			
,data as (			
select			
mon_year,			
mon_lastday,			
fiscalyear,			
fiscalyear_mon,			
opportunity_id,				
stage_name,			
opp_record_type ,			
sfdc_account_id,			
sfdc_state_initiative,					
sfdc_ultimate_parent_id,			
invoiced_date ,			
close_date,			
start_date,			
end_date,			
renewal_opportunity_id,			
renewal_stage_name,			
renewal_invoiced_date,			
renewal_close_date,			
disable_auto_renewal_opp,			
license_unenforced,			
Bucket,			
amount			
from ARR_data			
union all			
select			
mon_year,			
mon_lastday,			
fiscalyear,			
fiscalyear_mon,			
opportunity_id,			
stage_name,			
opp_record_type ,			
sfdc_account_id,			
sfdc_state_initiative,				
sfdc_ultimate_parent_id,			
invoiced_date ,			
close_date,			
start_date,			
end_date,			
renewal_opportunity_id,			
renewal_stage_name,			
renewal_invoiced_date,			
renewal_close_date,			
disable_auto_renewal_opp,			
license_unenforced,			
Bucket,			
amount			
expected_mon_year			
from Price_Increase_data			
union all			
select			
mon_year,			
mon_lastday,			
fiscalyear,			
fiscalyear_mon,			
opportunity_id,					
stage_name,			
opp_record_type ,			
sfdc_account_id,			
sfdc_state_initiative,			
sfdc_ultimate_parent_id,			
invoiced_date ,			
close_date,			
start_date,			
end_date,			
renewal_opportunity_id,			
renewal_stage_name,			
renewal_invoiced_date,			
renewal_close_date,			
disable_auto_renewal_opp,			
license_unenforced,			
Bucket,			
amount			
from Reduction_data			
union all			
select			
mon_year,			
mon_lastday,			
fiscalyear,			
fiscalyear_mon,			
opportunity_id,					
stage_name,			
opp_record_type ,			
sfdc_account_id,			
sfdc_state_initiative,				
sfdc_ultimate_parent_id,			
invoiced_date ,			
close_date,			
start_date,			
end_date,			
renewal_opportunity_id,			
renewal_stage_name,			
renewal_invoiced_date,			
renewal_close_date,			
disable_auto_renewal_opp,			
license_unenforced,			
Bucket,			
amount			
from cancellation_data cellation_data			
)			
select			
mon_year::integer,			
mon_lastday::date,			
fiscalyear::varchar(20),			
fiscalyear_mon::integer,			
opportunity_id::varchar(300),				
stage_name::varchar(780),			
opp_record_type::varchar(20) ,			
sfdc_account_id::varchar(300),			
sfdc_state_initiative::boolean,				
sfdc_ultimate_parent_id::varchar(300),			
invoiced_date::date ,			
close_date::date,			
start_date::date,			
end_date::date,			
renewal_opportunity_id::varchar(30),			
isnull(renewal_stage_name,'Unknown')::varchar(780) renewal_stage_name,			
isnull(renewal_invoiced_date,'1900-01-01')::date renewal_invoiced_date,			
isnull(renewal_close_date,'1900-01-01')::date renewal_close_date,			
disable_auto_renewal_opp::boolean,			
license_unenforced::boolean,			
Bucket::varchar(765),			
amount::numeric(38,10)		
,'{{ var("loaddate") }}'::timestamp as loaddate	
from data