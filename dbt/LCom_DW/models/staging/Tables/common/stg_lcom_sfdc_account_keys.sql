{{
    config(
        materialized='table',
        dist='all',
        sort='account_id'
    )
}}

select
    id as account_id,
    lcom_organization_c as lcom_organization_c_id
from {{ source('fivetran_salesforce_quickstart', 'account') }}
