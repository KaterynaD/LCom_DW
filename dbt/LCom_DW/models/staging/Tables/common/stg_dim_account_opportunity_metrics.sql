{{
    config(
        materialized='table',
        dist='account_id',
        sort='account_id'
    )
}}

select
    account_id,
    count(distinct case
        when stage_name ilike '%won%'
            and invoiced_date_c is not null
            then id
    end) as total_won_opportunities,
    count(distinct case
        when stage_name not ilike '%won%'
            and stage_name not ilike '%lost%'
            then id
    end) as total_open_opportunities,
    max(case
        when stage_name ilike '%won%'
            and invoiced_date_c is not null
            then start_date_c
    end)::date as latest_start_date,
    max(case
        when stage_name ilike '%won%'
            and invoiced_date_c is not null
            then end_date_c
    end)::date as latest_end_date,
    max(case
        when stage_name not ilike '%won%'
            and stage_name not ilike '%lost%'
            then last_modified_date at time zone 'PST'
    end)::date as latest_open_opportunities_modified_date,
    min(case
        when stage_name ilike '%won%'
            and invoiced_date_c is not null
            then invoiced_date_c
    end)::date as first_invoiced_date
from {{ source('fivetran_salesforce_quickstart', 'opportunity') }}
where test_account_c = false
group by account_id
