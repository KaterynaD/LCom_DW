{{
    config(
        materialized='table',
        dist='organization_id',
        sort='organization_id'
    )
}}

select
    lower(lcom_organization.lcom_platform_organization_id_c) as organization_id,
    max(account.account_id) as salesforce_id
from {{ source('fivetran_salesforce_quickstart', 'lcom_organization_c') }} lcom_organization
join {{ ref('stg_lcom_sfdc_account_keys') }} account
    on account.lcom_organization_c_id = lcom_organization.id
where lcom_organization.lcom_platform_organization_id_c is not null
group by lower(lcom_organization.lcom_platform_organization_id_c)
