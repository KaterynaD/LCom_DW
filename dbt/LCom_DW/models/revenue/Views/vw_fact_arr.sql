{{ config(
    materialized = 'view',
    bind = false,
    post_hook = ['{{ validate_view() }}']
) }}

with
opportunities_issues as (
select 
a.opportunity_id,
listagg(i.issue, ', ') WITHIN GROUP (ORDER BY i.issue) AS  issues
from {{ ref('dim_arr_audit') }} a
join {{ ref('dim_arr_issue') }} i
on a.issue_id = i.issue_id
group by a.opportunity_id
)
    select 
        fa.arr_type, 
        fa.record_type,        
        fa.mon_year, 
        fa.mon_lastday,
        fa.fiscalyear,
        fa.fiscalyear_mon, 
        fa.bucket,
        fa.account_id,
        fa.opportunity_id,
        fa.sfdc_product_id,
        sum(total_price) as total_price,
        sum(parent_total_price) as parent_total_price,
        sum(fa.arr_amount) as arr_amount,
        max(loaddate) as loaddate
    from {{ ref('fact_arr') }} fa
    left outer join opportunities_issues i
    on fa.opportunity_id = i.opportunity_id             
    where current_date between fa.arr_activation_date and fa.arr_deactivation_date
      and isnull(i.issues,'Valid') not ilike '%negative opp%'
      and isnull(i.issues,'Valid') not ilike '%replacement opp%'                     
    group by
        fa.arr_type, 
        fa.record_type,        
        fa.mon_year, 
        fa.mon_lastday,
        fa.fiscalyear,
        fa.fiscalyear_mon, 
        fa.bucket,
        fa.account_id,
        fa.opportunity_id,
        fa.sfdc_product_id
