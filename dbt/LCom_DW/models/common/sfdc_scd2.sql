{{ config(
    materialized='sfdc_history_scd2',
    unique_key='contact_id',
    base_model='dim_contact',
    dummy_base_source = {'name': 'fivetran_salesforce_quickstart', 'table': 'contact'},
    first_fromdate='1900-01-01',
    last_todate='3000-12-31',
    fields_config = [
    {
        "source_field": "lead_Status__c",
        "type": "DynamicEnum",
        "default": "Unknown",
        "target_field": "lead_status"
    },
    {
        "source_field": "Account",
        "type": "EntityId",
        "default": "00000000-0000-0000-0000-000000000000",
        "target_field": "sfdc_account_id"
    },
    {
        "source_field": "Owner",
        "type": "EntityId",
        "default": "00000000-0000-0000-0000-000000000000",
        "target_field": "owner_id"
    },
    {
        "source_field": "MailingStateCode",
        "type": "DynamicEnum",
        "default": "Unknown",
        "target_field": "mailing_state_code"
    }
]
) }}

-- depends_on: {{ ref('dim_contact') }}
-- depends_on: {{ source('fivetran_salesforce_quickstart','contact') }}

select
contact_id,
created_date,
field,
data_type,
new_value,
old_value
from {{ source('fivetran_salesforce_quickstart', 'contact_history') }}
limit 100
