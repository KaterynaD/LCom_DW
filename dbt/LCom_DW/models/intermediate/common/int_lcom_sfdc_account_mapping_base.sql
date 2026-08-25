{{
    config(
        materialized='table',
        dist='salesforce_id',
        sort='salesforce_id'
    )
}}

select
    organization.organization_id,
    organization.organization_type,
    coalesce(direct_account.account_id, fallback_account.salesforce_id) as salesforce_id
from {{ source('dbo', 'organization') }} organization
left outer join {{ ref('stg_lcom_sfdc_account_keys') }} direct_account
    on direct_account.account_id = organization.salesforce_id
left outer join {{ ref('int_lcom_sfdc_account_fallback') }} fallback_account
    on fallback_account.organization_id = organization.organization_id
    and direct_account.account_id is null
where coalesce(direct_account.account_id, fallback_account.salesforce_id) is not null
