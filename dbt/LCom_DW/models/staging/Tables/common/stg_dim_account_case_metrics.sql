{{
    config(
        materialized='table',
        dist='account_id',
        sort='account_id'
    )
}}

select
    account_id,
    count(distinct id) as total_cases,
    count(distinct case
        when status not in ('Closed', 'Merged', 'Resolved')
            then id
    end) as currently_open_cases,
    max(created_date at time zone 'PST')::date as latest_case_created_date,
    max(case
        when status not in ('Closed', 'Merged', 'Resolved')
            then last_modified_date at time zone 'PST'
    end)::date as latest_open_case_modified_date
from {{ source('fivetran_salesforce_quickstart', 'case') }}
where is_deleted = false
group by account_id
