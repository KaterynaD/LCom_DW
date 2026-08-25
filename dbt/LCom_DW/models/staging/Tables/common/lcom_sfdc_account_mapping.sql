{{
    config(
        materialized='table',
        dist='organization_id',
        sort='organization_id'
    )
}}

with mapping_stats as (
    select
        organization_id,
        organization_type,
        salesforce_id,
        count(*) over (
            partition by salesforce_id
        ) as organization_count,
        sum(case when organization_type = 'district' then 1 else 0 end) over (
            partition by salesforce_id
        ) as district_count,
        sum(case when organization_type = 'school' then 1 else 0 end) over (
            partition by salesforce_id
        ) as school_count,
        max(case when organization_type = 'district' then organization_id end) over (
            partition by salesforce_id
        ) as max_district_organization_id,
        max(case when organization_type = 'school' then organization_id end) over (
            partition by salesforce_id
        ) as max_school_organization_id
    from {{ ref('int_lcom_sfdc_account_mapping_base') }}
), rule_applied as (
    select
        organization_id,
        organization_type,
        salesforce_id,
        case
            when organization_count = 1 then salesforce_id
            when organization_type = 'district' and district_count = 1 then salesforce_id
            when organization_type = 'district'
                and district_count > 1
                and organization_id = max_district_organization_id
                then salesforce_id
            when organization_type = 'school'
                and district_count = 0
                and school_count > 1
                and organization_id = max_school_organization_id
                then salesforce_id
            when organization_type in ('district', 'school') then 'dup-' + salesforce_id
        end as sfdc_account_id,
        case
            when organization_count = 1
                then 'No duplicates by salesforce_id in Organization.'
            when organization_type = 'district' and district_count = 1
                then 'District in Districts and Schools with duplicate salesforce_id in Organization'
            when organization_type = 'district'
                and district_count > 1
                and organization_id = max_district_organization_id
                then 'More then 1 district with duplicate salesforce_id in Organization. Max organization Id has precedence'
            when organization_type = 'school'
                and district_count = 0
                and school_count > 1
                and organization_id = max_school_organization_id
                then 'More then 1 schools with duplicate salesforce_id in Organization. Max organization Id has precedence'
            when organization_type in ('district', 'school') then 'Marked as duplicate'
        end as applied_rule,
        case when organization_count > 1 then organization_count end
            as cnt_dist_org_id_group_by_salesforce_id,
        case when organization_count > 1 then district_count end
            as cnt_districts_in_dups_by_salesforce_id,
        case when organization_count > 1 then school_count end
            as cnt_schools_in_dups_by_salesforce_id
    from mapping_stats
)

select
    organization_id::varchar(300),
    organization_type::varchar(270),
    salesforce_id::varchar(300),
    sfdc_account_id::varchar(300),
    applied_rule::varchar(150),
    cnt_dist_org_id_group_by_salesforce_id::integer,
    cnt_districts_in_dups_by_salesforce_id::integer,
    cnt_schools_in_dups_by_salesforce_id::integer
from rule_applied
where sfdc_account_id is not null
