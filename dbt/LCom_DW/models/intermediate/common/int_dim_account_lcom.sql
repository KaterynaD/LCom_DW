{{
    config(
        materialized='table',
        dist='organization_id',
        sort='organization_id'
    )
}}

select
    organization.organization_id,
    organization.organization_name,
    organization.organization_type,
    case
        when len(organization.parent_organization_id) < 1 then null
        else organization.parent_organization_id
    end as parent_organization_id,
    parent_organization.organization_name as parent_organization_name,
    organization.is_trial,
    organization.is_demo,
    organization.postal_code,
    organization.state_province_key,
    state_province.state_province_code,
    state_province.state_province_name,
    organization.country_code,
    country.country_name,
    country.alpha3_code,
    country.numeric_code,
    organization.external_sis_id,
    organization.nces_id,
    organization.created_datetime,
    organization.modified_datetime,
    organization.deleted_datetime
from {{ source('dbo', 'organization') }} organization
left outer join {{ source('dbo', 'organization') }} parent_organization
    on organization.parent_organization_id = parent_organization.organization_id
left outer join {{ source('dbo', 'state_province') }} state_province
    on state_province.state_province_key = organization.state_province_key
left outer join {{ source('dbo', 'country') }} country
    on country.country_code = organization.country_code

