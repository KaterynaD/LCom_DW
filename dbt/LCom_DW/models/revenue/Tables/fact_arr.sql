{{
    config(

        materialized='table',        
        dist='account_id' ,
        sort='mon_year'
        
        )
}}

with final_data as (
select
arr_type,    
record_type,
mon_year,
mon_lastday,
fiscalyear,
fiscalyear_mon,
account_id,
opportunity_id,
arr_activation_date,
arr_deactivation_date,
sfdc_product_id,
Bucket,
Bucket_SFDC,
total_price ,
parent_total_price,
--
case 
when bucket in (
'New Business: ARR',
'New Business: Biz Dev',
'Renewal: ARR',
'Renewal: Biz Dev',
'Reseller ARR Renewal',
'Reseller ARR Upsell',
'Starting: ARR',
'Starting: Biz Dev',
'Upsell: ARR',
'Upsell: Biz Dev'
) then
total_price
when bucket in (
'Expired: ARR',
'Expired: Biz Dev'
) then
-total_price
when bucket in (
'Cancellation: ARR',
'Cancaellation: Biz Dev'
) then
-parent_total_price
ELSE
total_price - parent_total_price
end as arr_amount
--
from {{ ref("int_fact_arr")}}
)
select
arr_type::varchar(20),    
record_type::varchar(20),
mon_year::integer,
mon_lastday::date,
fiscalyear::varchar(20),
fiscalyear_mon::integer,
account_id::varchar(300),
opportunity_id::varchar(300),
sfdc_product_id::varchar(300),
Bucket::varchar(100),
Bucket_SFDC::varchar(100),
total_price::numeric(38,10),
parent_total_price::numeric(38,10),
arr_amount::numeric(38,10),
arr_activation_date::date,
arr_deactivation_date::date
from final_data