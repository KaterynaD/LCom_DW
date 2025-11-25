{{ config(

   
   materialized='scd2_plus',
   
   unique_key='opportunity_line_id',

   check_cols=[
'sfdc_product_id', 
'opportunity_id', 
'pricebook_entry_id', 
'pricebook_id', 
'netsuite_id', 
'netsuite_sku',
'sbqq_quote_line', 
'name', 
'quantity', 
'total_price', 
'unit_price', 
'weighted_total_price', 
'combine_new_biz_arr', 
'combine_renewal_arrs', 
'combine_upsell_arrs', 
'discount_applied', 
'list_price', 
'net_price_display', 
'net_unit_price', 
'opportunity_product_arr', 
'pro_rate_adj_term', 
'record_type', 
'business_type_opty_product', 
'class'],


   updated_at='last_modified_date',

   scd_id_col_name = 'opportunity_line_hist_id',
   scd_valid_from_col_name='fromdate',
   scd_valid_to_col_name='todate',
   scd_record_version_col_name='record_version',
   scd_loaddate_col_name='loaddate',
   scd_updatedate_col_name='updatedate',
   
   scd_valid_from_min_date='1900-01-01',
   scd_valid_to_max_date='3000-12-31' ,

   loaddate = var('loaddate'),

   dist='opportunity_id', 
   sort='fromdate' 
) }}

SELECT 
opportunity_line_id, 
sfdc_product_id, 
opportunity_id, 
pricebook_entry_id, 
pricebook_id, 
netsuite_id, 
netsuite_sku,
sbqq_quote_line, 
name, 
quantity, 
total_price, 
unit_price, 
weighted_total_price, 
combine_new_biz_arr, 
combine_renewal_arrs, 
combine_upsell_arrs, 
discount_applied, 
list_price, 
net_price_display, 
net_unit_price, 
opportunity_product_arr, 
pro_rate_adj_term, 
record_type, 
business_type_opty_product, 
class, 
last_modified_date
FROM {{ ref("dim_opportunity_line") }} 
