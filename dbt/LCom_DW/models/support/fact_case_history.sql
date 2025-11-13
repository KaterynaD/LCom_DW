{{ config(

   
   materialized='scd2_plus',
   
   unique_key='case_id',

   check_cols=['is_closed','is_escalated','closed_date','case_priority','owner_id','escalation_status','status'],


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
case_id,
case when is_closed=True then 1 else 0 end as is_closed,
case when is_escalated=True then 1 else 0 end as is_escalated,
closed_date,
case_priority,
account_id,
owner_id,
escalation_status,
status,
last_modified_date 
from {{ ref("fact_case") }}
{% if is_incremental() %}
 where coalesce(last_modified_date,created_date,'1900-01-01') >= (select coalesce(max(t.last_modified_date),'1900-01-01') from {{ this }} t)
{% endif %}