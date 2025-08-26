{{ config(

   
   materialized='scd2_plus',
   
   unique_key='training_session_id',

   check_cols=['status','owner_id', 'pds_group'],

   punch_thru_cols=['account_id'],

   updated_at='last_modified_date',

   scd_id_col_name = 'training_session_hist_id',
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
training_session_id,
account_id,
status,
owner_id,
pds_group,
last_modified_date 
from {{ ref("fact_training_session") }}
{% if is_incremental() %}
 where coalesce(last_modified_date,created_date,'1900-01-01') >= (select coalesce(max(t.last_modified_date),'1900-01-01') from {{ this }} t)
{% endif %}