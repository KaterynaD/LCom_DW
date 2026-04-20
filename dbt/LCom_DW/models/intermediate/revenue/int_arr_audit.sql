{{
    config(

        materialized='table',        
        dist='opportunity_id' 
        
        )
}}

with data as (
select to_char(o.start_date,'yyyymm')::int mon_year, o.opportunity_id, 'Won, Invoiced, Empty Start or End Dates' issue, 'Not Included in ARR' category
from {{ ref('fact_opportunity') }} o
where o.stage_name ilike '%won%'
and o.invoiced_date != '1900-01-01'
and (o.start_date='1900-01-01'  or o.end_date='1900-01-01')
union all
select to_char(o.start_date,'yyyymm')::int mon_year, o.opportunity_id, 'Not Recurring Revenue' issue, 'Included in ARR' category
from {{ ref('stg_arr_base') }} b
join {{ ref('fact_opportunity') }} o
on b.opportunity_id = o.opportunity_id
where o.stage_name ilike '%won%'
and o.invoiced_date != '1900-01-01'
and o.renewal_opportunity_id = 'Unknown'
union all
select to_char(o.start_date,'yyyymm')::int mon_year, o.opportunity_id, 'Won, not Invoiced' issue, 'Not Included in ARR' category
from  {{ ref('fact_opportunity') }} o
where o.stage_name ilike '%won%'
and o.invoiced_date = '1900-01-01'
union all
select to_char(o.start_date,'yyyymm')::int mon_year, o.opportunity_id, 'Negative or Replacement' issue, 'Not Included in ARR' category
from {{ ref('fact_opportunity') }} o
where o.name ilike '%NEGATIVE OPP%' or o.name ilike '%REPLACEMENT OPP%'
and o.invoiced_date != '1900-01-01'
union all
select to_char(o.start_date,'yyyymm')::int mon_year, o.opportunity_id, 'Won Start Date after End Date' issue, 'Potential ARR Impact' category
from {{ ref('stg_arr_base') }} b
join {{ ref('fact_opportunity') }} o
on b.opportunity_id = o.opportunity_id
where  
o.stage_name ilike '%won%'
and o.invoiced_date != '1900-01-01'
and o.start_date!='1900-01-01'
and o.start_date >= o.end_date
union all
select to_char(ro.start_date,'yyyymm')::int mon_year, ro.opportunity_id, 'Won Renewal Start or End Date before Parent Start or End Date' issue, 'Potential ARR Impact' category
from {{ ref('stg_arr_base') }} b
join {{ ref('fact_opportunity') }} o
on b.opportunity_id = o.opportunity_id
join {{ ref('fact_opportunity') }} ro
on ro.opportunity_id = o.renewal_opportunity_id
where  
(o.stage_name ilike '%won%' and o.invoiced_date != '1900-01-01')
and
(ro.stage_name ilike '%won%' and ro.invoiced_date != '1900-01-01')
and ((ro.start_date <= o.start_date) or (ro.end_date <= o.end_date))
union all
select to_char(ro.start_date,'yyyymm')::int mon_year, ro.opportunity_id, 'Won Renewal Start or End Date are the same as Parent Start or End Date' issue, 'Potential ARR Impact' category
from {{ ref('stg_arr_base') }} b
join {{ ref('fact_opportunity') }} o
on b.opportunity_id = o.opportunity_id
join {{ ref('fact_opportunity') }} ro
on ro.opportunity_id = o.renewal_opportunity_id
where  
(o.stage_name ilike '%won%' and o.invoiced_date != '1900-01-01')
and
(ro.stage_name ilike '%won%' and ro.invoiced_date != '1900-01-01')
and ((ro.start_date = o.start_date) or (ro.end_date = o.end_date))
/*union all
select to_char(o.start_date,'yyyymm')::int mon_year, o.opportunity_id, 'Lost Renewal Start Date after End Date or missing' issue, 'Included in ARR' category
from {{ ref('stg_arr_base') }} b
join {{ ref('fact_opportunity') }} o
on b.opportunity_id = o.opportunity_id
where  
(o.stage_name = 'Closed Lost' and o.close_date != '1900-01-01')
and o.start_date >= o.end_date
union all
select to_char(ro.start_date,'yyyymm')::int mon_year, ro.opportunity_id, 'Lost Renewal Start Date before Parent Start or End Date' issue, 'Included in ARR' category
from {{ ref('stg_arr_base') }} b
join {{ ref('fact_opportunity') }} o
on b.opportunity_id = o.opportunity_id
join {{ ref('fact_opportunity') }} ro
on ro.opportunity_id = o.renewal_opportunity_id
where  
(o.stage_name ilike '%won%' and o.invoiced_date != '1900-01-01')
and
(ro.stage_name = 'Closed Lost' and o.close_date != '1900-01-01')
and ((ro.start_date <= o.start_date) or (ro.end_date <= o.end_date))*/
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
select mon_year, opportunity_id, issue, category from data
)
select distinct
mon_year::int,
opportunity_id::varchar(300),
issue::varchar(100),
category::varchar(100),
'{{ var("loaddate") }}'::timestamp as loaddate
from final_data
where mon_year <= to_char(GetDate(),'yyyymm')