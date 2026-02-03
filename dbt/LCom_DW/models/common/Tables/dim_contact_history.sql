{{ config(

   
   materialized='scd2_plus',
   
   unique_key='contact_id',

   check_cols=['lead_status',  'owner_id', 'mailing_state_code', 'sfdc_account_id', 'last_modified_by_id'],

   punch_thru_cols=['account_id'],

   updated_at='last_modified_date',

   scd_id_col_name = 'contact_hist_id',
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
contact_id, 
account_id,
lead_status,  
owner_id, 
mailing_state_code,
sfdc_account_id,
last_modified_by_id,
last_modified_date
from {{ ref("dim_contact") }}
{% if is_incremental() %}
 where coalesce(last_modified_date,created_date,'1900-01-01') >= (select coalesce(max(t.last_modified_date),'1900-01-01') from {{ this }} t)
{% endif %}