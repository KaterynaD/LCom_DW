{{
    config(

        materialized='table',        
        dist='opportunity_id' 
        
        )
}}

with data as (
select to_char(o.start_date,'yyyymm')::int mon_year, o.opportunity_id, 'Empty Start/End Dates' issue
from {{ ref('fact_opportunity') }} o
where o.stage_name ilike '%won%'
and o.invoiced_date != '1900-01-01'
and (o.start_date='1900-01-01'  or o.end_date='1900-01-01')
union all
select to_char(o.start_date,'yyyymm')::int mon_year, o.opportunity_id, 'Not Recurring Revenue' issue
from {{ ref('fact_opportunity') }} o
where o.stage_name ilike '%won%'
and o.invoiced_date != '1900-01-01'
and o.renewal_opportunity_id = 'Unknown'
union all
select to_char(o.start_date,'yyyymm')::int mon_year, o.opportunity_id, 'Won, not Invoiced' issue
from  {{ ref('fact_opportunity') }} o
where o.stage_name ilike '%won%'
and o.invoiced_date = '1900-01-01'
union all
select to_char(o.start_date,'yyyymm')::int mon_year, o.opportunity_id, 'Negative Opp' issue
from {{ ref('fact_opportunity') }} o
where o.name ilike '%NEGATIVE OPP%'
and o.invoiced_date != '1900-01-01'
union all
select to_char(o.start_date,'yyyymm')::int mon_year, o.opportunity_id, 'Replacement Opp' issue
from {{ ref('fact_opportunity') }} o
where o.name ilike '%REPLACEMENT OPP%'
and o.invoiced_date != '1900-01-01'
union all
select to_char(o.start_date,'yyyymm')::int mon_year, o.opportunity_id, 'Start Date >= End Date' issue
from {{ ref('fact_opportunity') }} o
where  
o.stage_name ilike '%won%'
and o.invoiced_date != '1900-01-01'
and o.start_date!='1900-01-01'
and o.start_date >= o.end_date
union all
select to_char(ro.start_date,'yyyymm')::int mon_year, ro.opportunity_id, 'Renewal dates precede parent dates' issue
from  {{ ref('fact_opportunity') }} o
join {{ ref('fact_opportunity') }} ro
on ro.opportunity_id = o.renewal_opportunity_id
where  
(o.stage_name ilike '%won%' and o.invoiced_date != '1900-01-01')
and
(ro.stage_name ilike '%won%' and ro.invoiced_date != '1900-01-01')
and ((ro.start_date <= o.start_date) or (ro.end_date <= o.end_date))
union all
select to_char(o.start_date,'yyyymm')::int mon_year, o.opportunity_id, 'Negative ARR' issue
from {{ ref('stg_arr_base') }} b
join {{ ref('fact_opportunity') }} o
on b.opportunity_id = o.opportunity_id
where  
b.total_price<0
)
,other as (
select opportunity_id
from {{ ref('int_arr_base') }} iab 
/*won, invoiced, in a past must be in ARR calculation*/
where stage_name ilike '%won%' and invoiced_date!='1900-01-01' and invoiced_date <= trunc(GetDate()) and start_date_sfdc <= trunc(GetDate())
except
select opportunity_id
from {{ ref('fact_arr') }}
)
,final_data as (
select 
to_char(o.start_date,'yyyymm')::int mon_year, o.opportunity_id, 'Other' as issue, 'Other' category
from
(
select opportunity_id
from other
except
select opportunity_id
from data
) b
join {{ ref('fact_opportunity') }} o
on b.opportunity_id = o.opportunity_id
union all
select distinct data.mon_year, data.opportunity_id, data.issue, case when f.opportunity_id is not null then 'Included in ARR' else 'Not Included in ARR' end as category
from data
left outer join {{ ref('fact_arr') }} f
on data.opportunity_id = f.opportunity_id
)
select distinct
mon_year::int,
opportunity_id::varchar(300),
issue::varchar(100),
category::varchar(100),
'{{ var("loaddate") }}'::timestamp as loaddate
from final_data
where mon_year <= to_char(GetDate(),'yyyymm')