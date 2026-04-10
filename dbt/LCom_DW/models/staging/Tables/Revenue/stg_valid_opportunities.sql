{{
    config(

        materialized='table',        
        dist='opportunity_id' 
        
        )
}}

with valid_won_opportunities as
(
--staging is won, invoiced and have populated start and end dates
select fo.opportunity_id,fo.renewal_opportunity_id
from {{ ref("fact_opportunity") }} fo
where fo.stage_name ilike '%won%'
and fo.invoiced_date != '1900-01-01'
and fo.start_date!='1900-01-01'
and fo.end_date!='1900-01-01'
)
,valid_lost_opportunities as
(
--renew only valid won opportunities
 --staging is Lost, close date is populated
select distinct fo.opportunity_id
from {{ ref("fact_opportunity") }} fo
join valid_won_opportunities pfo
on fo.opportunity_id = pfo.renewal_opportunity_id
where fo.stage_name = 'Closed Lost'
and fo.close_date != '1900-01-01'
--if there is no start date parent opportunity end date is used
)
select opportunity_id::varchar(300) from valid_won_opportunities
union all
select opportunity_id::varchar(300) from valid_lost_opportunities
