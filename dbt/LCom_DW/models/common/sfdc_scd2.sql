{{ config(
    materialized='sfdc_history_scd2',
    unique_key='contact_id',
    base_relation=ref('dim_contact'),
    first_fromdate='1900-01-01',
    last_todate='3000-12-31',
    fields_config=[
        ('lead_Status__c','DynamicEnum','Unknown','lead_status'),
        ('Account','EntityId','00000000-0000-0000-0000-000000000000','sfdc_account_id'),
        ('Owner','EntityId','00000000-0000-0000-0000-000000000000','owner_id'),
        ('MailingStateCode','DynamicEnum','Unknown','mailing_state_code')
    ]
) }}

select
contact_id,
created_date,
field,
data_type,
new_value,
old_value
from {{ source('fivetran_salesforce_quickstart', 'contact_history') }}
