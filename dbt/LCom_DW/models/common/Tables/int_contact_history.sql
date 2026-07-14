{{ config(materialized='ephemeral') }}
select 
contact_id, 
account_id,
lead_status,  
owner_id, 
mailing_state_code,
sfdc_account_id,
last_modified_by_id,
created_date,
last_modified_date
from {{ ref("dim_contact") }}