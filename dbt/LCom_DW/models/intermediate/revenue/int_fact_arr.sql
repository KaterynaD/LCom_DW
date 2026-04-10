{{
    config(

        materialized='table',        
        dist='opportunity_id' ,
        sort='mon_year'
        
        )
}}

with dim_month as --Thread to calculate monthly metrics 
(select
c.mon_year,
c.mon_firstday,
c.mon_lastday,
c.fiscalyear,
c.fiscalyear_mon,
c.fiscalyear_startdate,
c.fiscalyear_enddate
from {{ ref("dim_month") }} c
where
mon_year<=to_char(Getdate(),'yyyymm')::int
)
,ARR_data as
(
--extend Starting to each month in the fiscal year for running total 
select
ARR_Type,
'ARR' record_type,
mon.mon_year,
mon.mon_lastday,
mon.fiscalyear,
mon.fiscalyear_mon,
HasParent,
opportunity_id,
stage_name,
account_id,
invoiced_date,
close_date,
start_date,
start_date_sfdc,
end_date,
end_date_sfdc,
arr_activation_date,
arr_deactivation_date,
renewal_opportunity_id,
renewal_stage_name,
renewal_invoiced_date,
renewal_close_date,
renewal_start_date,
renewal_start_date_sfdc,
renewal_end_date,
sfdc_product_id,
Bucket,
Bucket_SFDC,
total_price ,
parent_total_price,
max_parent_end_date,
max_parent_end_date_sfdc
from {{ ref("int_arr_monthly_changes")}} st
join dim_month mon
on st.mon_lastday between mon.fiscalyear_startdate and mon.fiscalyear_enddate
where st.record_type='ARR-Starting'
union all
--extend Added Monthly to each month in the fiscal year for running total 
select
ARR_Type,
'ARR' record_type,
mon.mon_year,
mon.mon_lastday,
mon.fiscalyear,
mon.fiscalyear_mon,
HasParent,
opportunity_id,
stage_name,
account_id,
invoiced_date,
close_date,
start_date,
start_date_sfdc,
end_date,
end_date_sfdc,
arr_activation_date,
arr_deactivation_date,
renewal_opportunity_id,
renewal_stage_name,
renewal_invoiced_date,
renewal_close_date,
renewal_start_date,
renewal_start_date_sfdc,
renewal_end_date,
sfdc_product_id,
Bucket,
Bucket_SFDC,
total_price ,
parent_total_price,
max_parent_end_date,
max_parent_end_date_sfdc
from {{ ref("int_arr_monthly_changes")}} eam
join dim_month mon
on eam.fiscalyear=mon.fiscalyear
and eam.mon_lastday<=mon.mon_lastday
where eam.record_type='ARR-MonthlyAdded'
/* till what month Need to add limit end date unless there is a renewal */
union all
--extend reduced Monthly to each month in the fiscal year for running total 
select
ARR_Type,
'ARR' record_type,
mon.mon_year,
mon.mon_lastday,
mon.fiscalyear,
mon.fiscalyear_mon,
HasParent,
opportunity_id,
stage_name,
account_id,
invoiced_date,
close_date,
start_date,
start_date_sfdc,
end_date,
end_date_sfdc,
arr_activation_date,
arr_deactivation_date,
renewal_opportunity_id,
renewal_stage_name,
renewal_invoiced_date,
renewal_close_date,
renewal_start_date,
renewal_start_date_sfdc,
renewal_end_date,
sfdc_product_id,
Bucket,
Bucket_SFDC,
total_price ,
parent_total_price,
max_parent_end_date,
max_parent_end_date_sfdc
from {{ ref("int_arr_monthly_changes")}} erm
join dim_month mon
on erm.fiscalyear=mon.fiscalyear
and erm.mon_lastday<=mon.mon_lastday
where erm.record_type='ARR-MonthlyReduced'
)
--
--
,final_data as
(
select
*
from ARR_data
union all
select
*
from {{ ref("int_arr_monthly_changes")}}
)
select
ARR_Type::varchar(20) as arr_type,    
record_type::varchar(20),
mon_year::integer,
mon_lastday::date,
fiscalyear::varchar(20),
fiscalyear_mon::integer,
HasParent::boolean,
opportunity_id::varchar(300),
stage_name::varchar(780),
account_id::varchar(300),
invoiced_date::date,
close_date::date,
start_date::date,
start_date_sfdc::date,
end_date::date,
end_date_sfdc::date,
arr_activation_date::date,
arr_deactivation_date::date,
renewal_opportunity_id::varchar(300),
renewal_stage_name::varchar(780),
renewal_invoiced_date::date,
renewal_close_date::date,
renewal_start_date::date,
renewal_start_date_sfdc::date,
renewal_end_date::date,
sfdc_product_id::varchar(300),
Bucket::varchar(100),
Bucket_SFDC::varchar(100),
total_price::numeric(38,10),
parent_total_price::numeric(38,10),
max_parent_end_date::date,
max_parent_end_date_sfdc::date
from final_data
