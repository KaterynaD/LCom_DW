{{
    config(
        materialized='table',
        dist='id',
        sort='id'
    )
}}

with school_rollup as (
    select
        parent_id,
        bool_or(state_initiative_c) as school_state_initiative_c,
        bool_or(district_state_initiative_c) as school_district_state_initiative_c
    from {{ ref('stg_dim_account_sfdc_account') }}
    where isnull(record_type_c, '{{ var("default_varchar") }}') != 'L'
    group by parent_id
)

select
    sfdc_account.*,
    school_rollup.school_state_initiative_c as state_initiative_school,
    school_rollup.school_district_state_initiative_c as district_state_initiative_school,
    parent_account.state_initiative_c as state_initiative_district,
    parent_account.district_state_initiative_c as district_state_initiative_district,
    lower(lcom_organization.lcom_platform_organization_id_c) as lcom_organization_id,
    parent_account.name as parent_name_proper_case_c,
    ultimate_parent_account.name as ultimate_parent_account_c,
    ultimate_parent_account.billing_state as ultimate_parent_billing_state_c,
    ultimate_parent_account.owner_name_text_c as ultimate_account_owner_c,
    opportunity_metrics.total_won_opportunities,
    opportunity_metrics.total_open_opportunities,
    opportunity_metrics.latest_start_date,
    opportunity_metrics.latest_end_date,
    opportunity_metrics.latest_open_opportunities_modified_date,
    opportunity_metrics.first_invoiced_date,
    training_session_metrics.total_training_sessions,
    training_session_metrics.latest_training_session_on,
    case_metrics.total_cases,
    case_metrics.currently_open_cases,
    case_metrics.latest_case_created_date,
    case_metrics.latest_open_case_modified_date
from {{ ref('stg_dim_account_sfdc_account') }} sfdc_account
left outer join {{ source('fivetran_salesforce_quickstart', 'lcom_organization_c') }} lcom_organization
    on sfdc_account.lcom_organization_c = lcom_organization.id
left outer join school_rollup
    on sfdc_account.id = school_rollup.parent_id
left outer join {{ ref('stg_dim_account_sfdc_account') }} parent_account
    on sfdc_account.parent_id = parent_account.id
left outer join {{ ref('stg_dim_account_sfdc_account') }} ultimate_parent_account
    on sfdc_account.ultimate_parent_id_c = ultimate_parent_account.id
left outer join {{ ref('stg_dim_account_opportunity_metrics') }} opportunity_metrics
    on sfdc_account.id = opportunity_metrics.account_id
left outer join {{ ref('stg_dim_account_training_session_metrics') }} training_session_metrics
    on sfdc_account.id = training_session_metrics.account_id
left outer join {{ ref('stg_dim_account_case_metrics') }} case_metrics
    on sfdc_account.id = case_metrics.account_id
