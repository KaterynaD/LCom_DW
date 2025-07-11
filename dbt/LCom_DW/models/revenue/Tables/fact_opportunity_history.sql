{{ config(

   
   materialized='scd2_plus',
   
   unique_key='opportunity_id',

   check_cols=['stage_name','name','amount','amount_won','arr','arr_new_business','arr_renewal','arr_upsell',
'arr_won','combined_arr','downsell','expected_new_business_arr',
'expected_revenue','multi_year_arr','new_biz_arr_trigger','nnarr','nrr_renewal','owner_closed_won',
'owner_open_pipeline','owner_quota','owner_sales_quota',
'pipeline_needed_to_hit_quota','po_amount','price_increase_arr',
'probability','quote_list_amount','quote_total_discount','remaining_quota',
'renewable_revenue','renewal_at_79','renewal_biz_trigger','total_arr_bookings',
'total_credit_from_opp_product','total_opportunity_quantity','true_arr',
'true_arr_formula','true_renewal_arr','variance','last_modified_date',
'invoiced_date','close_date','start_date','end_date','opp_record_type',
'license_unenforced','disable_auto_renewal_opp'],

   punch_thru_cols=['account_id'],

   updated_at='last_modified_date',

   scd_id_col_name = 'opportunity_hist_id',
   scd_valid_from_col_name='fromdate',
   scd_valid_to_col_name='todate',
   scd_record_version_col_name='record_version',
   scd_loaddate_col_name='loaddate',
   scd_updatedate_col_name='updatedate',
   
   scd_valid_from_min_date='1900-01-01',
   scd_valid_to_max_date='3000-12-31' ,

   loaddate = var('loaddate'),

   dist='account_id', 
   sort='fromdate' 
) }}

select 
opportunity_id,
name,
stage_name,
account_id,
amount	,
amount_won	,
arr	,
arr_new_business	,
arr_renewal	,
arr_upsell	,
arr_won	,
combined_arr	,
downsell	,	
expected_new_business_arr	,	
expected_revenue	,
multi_year_arr	,	
new_biz_arr_trigger	,	
nnarr	,	
nrr_renewal	,	
owner_closed_won	,	
owner_open_pipeline	,	
owner_quota	,	
owner_sales_quota	,	
pipeline_needed_to_hit_quota	,	
po_amount	,	
price_increase_arr	,	
probability	,	
quote_list_amount	,
quote_total_discount	,
remaining_quota	,
renewable_revenue	,
renewal_at_79	,
renewal_biz_trigger	,
total_arr_bookings	,
total_credit_from_opp_product	,
total_opportunity_quantity	,
true_arr	,
true_arr_formula	,
true_renewal_arr	,
variance ,
invoiced_date ,
close_date ,
start_date ,
end_date ,
opp_record_type ,
case when license_unenforced then 1 else 0 end  as license_unenforced ,
case when disable_auto_renewal_opp then 1 else 0 end as disable_auto_renewal_opp ,
last_modified_date 
from {{ ref("fact_opportunity") }}
{% if is_incremental() %}
 where coalesce(last_modified_date,created_date,'1900-01-01') >= (select coalesce(max(t.last_modified_date),'1900-01-01') from {{ this }} t)
{% endif %}