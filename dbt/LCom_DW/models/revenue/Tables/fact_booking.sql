{{
    config(

        materialized='table',        
        dist='account_id' ,
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
from dw.common.dim_month c
where
mon_year<=to_char(Getdate(),'yyyymm')::int
)
/*Won Invoiced Opportunities*/
,data as 
(
select
fo.account_id,
fo.opportunity_id,
fo.invoiced_date,
d.sfdc_product_id ,
d.bucket ,
d.total_price
from {{ ref('stg_arr_base') }} d
join {{ ref('fact_opportunity') }} fo
on fo.opportunity_id=d.opportunity_id
where fo.stage_name ilike '%won%'
and fo.invoiced_date != '1900-01-01'
)
/*fiscal calendar data*/
, booking_monthly_data as
(
select
'MonthlyBooking' record_type,
cal.mon_year,
cal.mon_lastday,
cal.fiscalyear,
cal.fiscalyear_mon,
d.account_id,
d.opportunity_id,
d.sfdc_product_id ,
d.bucket ,
d.total_price
from Data d
join dim_month cal
on
d.invoiced_date between cal.mon_firstday and cal.mon_lastday
)
--extend Actual Monthly data to each month in the fiscal year for running total 
,booking_data as
(
select
'Booking' record_type,
mon.mon_year,
mon.mon_lastday,
mon.fiscalyear,
mon.fiscalyear_mon,
b.account_id,
b.opportunity_id,
b.sfdc_product_id ,
b.bucket ,
b.total_price
from booking_monthly_data b
join dim_month mon
on b.fiscalyear=mon.fiscalyear
and b.mon_lastday<=mon.mon_lastday
)
--
,final_data as
(
select
*
from booking_data
union all
select
*
from booking_monthly_data
)
select
record_type::varchar(20),
mon_year::integer,
mon_lastday::date,
fiscalyear::varchar(20),
fiscalyear_mon::integer,
account_id::varchar(300),
opportunity_id::varchar(300),
sfdc_product_id::varchar(300),
bucket::varchar(100),
total_price::numeric(38,10)
from final_data
where mon_year!=0
