{{ config(

   
   materialized='scd2_plus',
   
   unique_key='case_id',

   check_cols=['is_closed','is_escalated','closed_date','case_priority','owner_id','status'],


   punch_thru_cols=['account_id'],

   updated_at='last_modified_date',

   scd_id_col_name = 'case_hist_id',
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
*
from {{ ref("int_case_history") }}
{% if is_scd2_update_run() %}
where coalesce(last_modified_date,created_date,'1900-01-01') >= (select coalesce(max(t.{{  config.get("scd_valid_from_col_name")  }}),'1900-01-01') from {{ this }} t)
{% endif %}