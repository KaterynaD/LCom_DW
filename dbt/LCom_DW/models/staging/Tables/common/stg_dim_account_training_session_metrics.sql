{{
    config(
        materialized='table',
        dist='account_id',
        sort='account_id'
    )
}}

select
    account_id_c as account_id,
    count(distinct case when status_c = 'Completed' then id end) as total_training_sessions,
    max(cast(end_date_c as varchar)::date) as latest_training_session_on
from {{ source('fivetran_salesforce_quickstart', 'training_session_c') }}
group by account_id_c
