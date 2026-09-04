{{
    config(
        materialized='table',
        dist='account_id',
        sort='account_id'
    )
}}

with cases as (
select
    account_id,
    count(distinct case_id) as total_cases,
    count(distinct case
        when status not in ('Closed', 'Merged', 'Resolved')
            then case_id
    end) as currently_open_cases,
    max(created_date)::date as latest_case_created_date,
    max(case
        when status not in ('Closed', 'Merged',  'Resolved')
            then last_modified_date
    end)::date as latest_open_case_modified_date
from {{ ref('fact_case') }}
group by account_id
)
,training_sessions as (select
    account_id as account_id,
    count(distinct case when status = 'Completed' then training_session_id end) as total_training_sessions,
    max(cast(end_date as varchar)::date) as latest_training_session_on
from {{ ref('fact_training_session') }}
group by account_id)
,opportunities as (select
    f.account_id,
    count(distinct case
        when f.stage_name ilike '%won%'
            and f.invoiced_date>'1900-01-01'
            then f.opportunity_id
    end) as total_won_opportunities,
    count(distinct case
        when f.stage_name not ilike '%won%'
            and f.stage_name not ilike '%lost%'
            then f.opportunity_id
    end) as total_open_opportunities,
    max(case
        when f.stage_name ilike '%won%'
            and f.invoiced_date>'1900-01-01'
            then f.start_date
    end) as latest_start_date,
    max(case
        when f.stage_name ilike '%won%'
            and f.invoiced_date>'1900-01-01'
            then f.end_date
    end) as latest_end_date,
    max(case
        when f.stage_name not ilike '%won%'
            and f.stage_name not ilike '%lost%'
            then f.last_modified_date
    end) as latest_open_opportunities_modified_date,
    min(case
        when f.stage_name ilike '%won%'
            and f.invoiced_date>'1900-01-01'
            then f.invoiced_date
    end) as first_invoiced_date,
    count(distinct
    case 
     when f.stage_name ilike '%won%'
            and f.invoiced_date>'1900-01-01'
            and d.business_type_opty_product ilike '%biz_dev%' 
            then d.opportunity_line_id
    end
    ) as total_won_state_program_deals,
    count(distinct case 
     when f.stage_name ilike '%won%'
            and f.invoiced_date>'1900-01-01' 
            then d.opportunity_line_id
    end) as total_won_deals
from {{ ref('fact_opportunity') }} f
join {{ ref('dim_opportunity_line') }} d
on f.opportunity_id = d.opportunity_id
group by account_id)
,product_usage as (
select distinct
    organization_school_id,
    organization_district_id
from {{ source('dbo', 'fact_assignment_launch') }}
)
,product_license as (
 select distinct
    organization_district_id as account_id
from {{ ref('fact_license_order') }}
union
select distinct
    organization_school_id as account_id
from {{ ref('dim_license_order_school') }}
)
select
a.account_id,
isnull(o.total_won_opportunities,{{ var("default_numeric") }})::integer as total_won_opportunities,
isnull(o.total_open_opportunities,{{ var("default_numeric") }})::integer as total_open_opportunities,
isnull(o.latest_start_date,'{{ var("default_date") }}')::date as latest_start_date,
isnull(o.latest_end_date,'{{ var("default_date") }}')::date as latest_end_date,
isnull(o.latest_open_opportunities_modified_date,'{{ var("default_date") }}')::date as latest_open_opportunities_modified_date,
isnull(o.first_invoiced_date,'{{ var("default_date") }}')::date as first_invoiced_date,
isnull(o.total_won_deals,{{ var("default_numeric") }})::integer as total_won_deals,
isnull(o.total_won_state_program_deals,{{ var("default_numeric") }})::integer as total_won_state_program_deals,
isnull(ts.total_training_sessions,{{ var("default_numeric") }})::integer as total_training_sessions,
isnull(ts.latest_training_session_on,'{{ var("default_date") }}')::date as latest_training_session_on,
isnull(c.total_cases,{{ var("default_numeric") }})::integer as total_cases,
isnull(c.currently_open_cases,{{ var("default_numeric") }})::integer as currently_open_cases,
isnull(c.latest_case_created_date,'{{ var("default_date") }}')::date as latest_case_created_date,
isnull(c.latest_open_case_modified_date,'{{ var("default_date") }}')::date as latest_open_case_modified_date,
max(case when pl.account_id is not null then 1 else 0 end )::boolean as has_product_licenses,
max(case when coalesce(pus.organization_school_id,pud.organization_district_id) is not null then 1 else 0 end)::boolean as has_product_usage
from {{ ref('dim_account') }} a
left outer join opportunities o
on a.account_id = o.account_id
left outer join cases c
on a.account_id = c.account_id
left outer join training_sessions ts
on a.account_id = ts.account_id
left outer join product_usage pus
on a.account_id = pus.organization_school_id
left outer join product_usage pud
on a.account_id = pud.organization_district_id
left outer join product_license pl
on a.account_id = pl.account_id
group by all
