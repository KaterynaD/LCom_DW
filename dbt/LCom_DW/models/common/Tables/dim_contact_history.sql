{{ config(

   
   materialized='scd2_plus',
   
   unique_key='contact_id',

   check_cols=['lead_status',  'key_contact', 'owner_id', 'mailing_state_code', 'sfdc_account_id'],

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
isnull(r.id,'{{ var("default_ID") }}') as contact_id, 
isnull(a.account_id,'{{ var("default_ID") }}') as account_id,
isnull(r.lead_status_c,'{{ var("default_varchar") }}') as lead_status, 
case when isnull(r.key_contact_c,{{ var("default_boolean") }}) then 1 else 0 end as key_contact,
isnull(r.owner_id,'{{ var("default_ID") }}') as owner_id, 
isnull(r.mailing_state_code,'{{ var("default_varchar") }}') as mailing_state_code,
isnull(a.sfdc_account_id,'{{ var("default_ID") }}') as sfdc_account_id,
isnull(r.last_modified_date AT TIME ZONE 'PST','{{ var("default_date") }}') as last_modified_date
from {{ source('fivetran_salesforce_quickstart', 'contact') }} as r
left outer join {{ref('dim_account') }} as a
        on r.account_id = a.sfdc_account_id
{% if is_incremental() %}
 where coalesce(r.last_modified_date AT TIME ZONE 'PST',r.created_date AT TIME ZONE 'PST','1900-01-01') >= (select coalesce(max(t.last_modified_date),'1900-01-01') from {{ this }} t)
{% endif %}