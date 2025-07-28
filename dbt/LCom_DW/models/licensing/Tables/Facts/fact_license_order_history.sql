{{ config(
   materialized='scd2_plus',
   
   unique_key='order_id',

   check_cols=['sku_id','organization_district_id','startdate','expirationdate','enforcedaterestrictions','SchoolCount', 'StudentCount'],
   update_cols=['auditupdatedate','netsuite_order_id'],

   updated_at='auditupdatedate',


   scd_id_col_name = 'order_hist_id',
   scd_valid_from_col_name='fromdate',
   scd_valid_to_col_name='todate',
   scd_record_version_col_name='record_version',
   scd_loaddate_col_name='loaddate',
   scd_updatedate_col_name='updatedate',
   
   scd_valid_from_min_date='1900-01-01',
   scd_valid_to_max_date='3000-12-31' ,

   loaddate = var('loaddate'),

   dist='organization_district_id', 
   sort='startdate'       

) }}


select
order_id,
sku_id,
organization_district_id,
startdate,
expirationdate,
enforcedaterestrictions,
netsuite_order_id,
SchoolCount, 
StudentCount,
auditupdatedate
from {{ ref("fact_license_order") }}
{% if is_incremental() %}
 where coalesce(auditupdatedate,'1900-01-01') >= (select coalesce(max(t.auditupdatedate),'1900-01-01') from {{ this }} t)
{% endif %}