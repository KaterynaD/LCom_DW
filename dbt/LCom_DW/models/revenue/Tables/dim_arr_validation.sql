{{
    config(

        materialized='table',        
        dist='opportunity_id' 
        
        )
}}
 
with current as (
select
r.arr_type,
socr.parent_opportunities,
r.opportunity_id,
r.arr_amount amount
from {{ ref("int_current_arr") }} r
join {{ ref("stg_opportunities_chain_of_renewals") }} socr
on r.opportunity_id = socr.opportunity_id
)
,calculated as (
select
r.arr_type,
r.opportunity_id,
socr.parent_opportunities,
sum(r.arr_amount) amount
from {{ ref("fact_arr") }} r
join {{ ref("stg_opportunities_chain_of_renewals") }}    socr
on r.opportunity_id = socr.opportunity_id
where r.record_type='ARR'
and to_char(GetDate(),'yyyymm')::int = r.mon_year
and GetDate() between arr_activation_date and arr_deactivation_date
group by all
)
,sum_current as
(
select
arr_type,
sum(amount) amount
from current
group by arr_type
)
,sum_calculated as
(
select
arr_type,
sum(amount) amount
from calculated
group by arr_type
)
,data_in_both as
(
select
s.arr_type,
e.opportunity_id calculated_opportunity_id,
s.opportunity_id current_opportunity_id,
e.amount calculated_amount,
s.amount current_amount
from
current s
join
calculated e
on 
s.arr_type = e.arr_type
and s.parent_opportunities like '%'+ e.opportunity_id+'%'
)
,data_in_both_aggregated as (
select
arr_type,
current_opportunity_id,
sum(calculated_amount) calculated_amount,
current_amount current_amount,
current_amount - sum(calculated_amount) diff
from data_in_both
group by arr_type,current_opportunity_id,current_amount
having abs(current_amount - sum(calculated_amount)) > 0.1
)
,data_current_not_in_calculated_raw as
(
select arr_type, opportunity_id from current
except
select arr_type, current_opportunity_id from data_in_both
)
,data_current_not_in_calculated_final as (
select
current.arr_type,
current.opportunity_id
from current
join data_current_not_in_calculated_raw as data
on 
    current.arr_type = data.arr_type
and current.opportunity_id = data.opportunity_id
where current.amount!=0
)
,data_calculated_not_in_current_raw as
(
select arr_type, opportunity_id from calculated
except
select arr_type, calculated_opportunity_id from data_in_both
)
,data_calculated_not_in_current as (
select
calculated.arr_type,
calculated.opportunity_id,
calculated.parent_opportunities
from calculated
join data_calculated_not_in_current_raw as data
on  calculated.arr_type = data.arr_type
and calculated.opportunity_id = data.opportunity_id
where calculated.amount!=0
order by abs(calculated.amount)
)
--excluding pairs of cancellated or expired with their parents which should not be in current by common sense
,data_calculated_not_in_current_paired as (
select p3.arr_type, p3.opportunity_id parent_opportunity_id, c3.opportunity_id renewal_opportunity_id
from data_calculated_not_in_current p3
join data_calculated_not_in_current c3
on  c3.arr_type = p3.arr_type
and c3.parent_opportunities ilike '%'+p3.opportunity_id+'%'
and c3.opportunity_id != p3.opportunity_id
)
,renewal_amount as (
select d.arr_type, d.renewal_opportunity_id, sum(distinct er.amount) renewal_amount /*multi parent renewals present more then 1 time in data_calculated_not_in_current_paired*/
from data_calculated_not_in_current_paired d
join calculated er
on  d.arr_type = er.arr_type
and d.renewal_opportunity_id = er.opportunity_id
group by d.arr_type, d.renewal_opportunity_id
)
,parent_amount as (
select d.arr_type, d.renewal_opportunity_id, LISTAGG(d.parent_opportunity_id, ',') WITHIN GROUP (ORDER BY d.parent_opportunity_id) parent_opportunities, sum(ep.amount) parent_amount
from data_calculated_not_in_current_paired d
join calculated ep
on d.arr_type = ep.arr_type
and d.parent_opportunity_id = ep.opportunity_id
group by d.arr_type, d.renewal_opportunity_id
)
,corrupted_pairs as (
select
pa.arr_type, pa.renewal_opportunity_id, pa.parent_amount, parent_opportunities, renewal_amount, pa.parent_amount+ca.renewal_amount diff
from parent_amount pa
join renewal_amount ca
on pa.arr_type = ca.arr_type
and pa.renewal_opportunity_id = ca.renewal_opportunity_id
where abs(pa.parent_amount+ca.renewal_amount) > 0.1
)
,corrupted_calculated as (
select e.arr_type,  e.opportunity_id, e.amount
from data_calculated_not_in_current_paired d
join corrupted_pairs cp
on d.arr_type = cp.arr_type
and d.renewal_opportunity_id = cp.renewal_opportunity_id
join calculated e
on d.arr_type = e.arr_type
and d.renewal_opportunity_id = e.opportunity_id
union
select e.arr_type,  e.opportunity_id, e.amount
from data_calculated_not_in_current_paired d
join corrupted_pairs cp
on d.arr_type = cp.arr_type
and d.renewal_opportunity_id = cp.renewal_opportunity_id
join calculated e
on d.arr_type = e.arr_type
and d.parent_opportunity_id = e.opportunity_id
)
,data_calculated_not_in_current_final as (
select arr_type, opportunity_id
from data_calculated_not_in_current
except
select arr_type, renewal_opportunity_id
from data_calculated_not_in_current_paired
except
select arr_type,  parent_opportunity_id
from data_calculated_not_in_current_paired
)
,final_data as (
select arr_type, 'Amount mismatch' as issue, current_opportunity_id as opportunity_id,current_amount, calculated_amount, diff 
from data_in_both_aggregated
union all
select e.arr_type, 'In Calculated ARR, not in Current' as issue, e.opportunity_id, null current_amount, sum(e.amount) calculated_amount, -sum(e.amount) diff 
from data_calculated_not_in_current_final d 
join calculated e on d.opportunity_id = e.opportunity_id 
group by e.arr_type, e.opportunity_id
union all
select e.arr_type,  'In Calculated ARR corrupted amount and not in Current' as issue, e.opportunity_id, null current_amount, sum(e.amount) calculated_amount, -sum(e.amount) diff 
from corrupted_calculated e 
group by e.arr_type, e.opportunity_id
union all
select s.arr_type,  'In Current ARR not in Calculated' as issue, s.opportunity_id,s.amount current_amount, null calculated_amount,s.amount diff 
from data_current_not_in_calculated_final d 
join current s 
on d.opportunity_id = s.opportunity_id
)
, audit as (
select
r.opportunity_id,
i.issue,
socr.parent_opportunities
from {{ ref("dim_arr_audit") }} r
join {{ ref("stg_opportunities_chain_of_renewals") }} socr
on r.opportunity_id = socr.opportunity_id
join {{ ref('dim_arr_issue') }} i
on r.issue_id =i.issue_id
) 
select distinct
v.arr_type::varchar(20), 
v.issue::varchar(100) as validation_issue, 
v.opportunity_id::varchar(300) as opportunity_id,
v.current_amount::numeric(38,10) as current_amount, 
v.calculated_amount::numeric(38,10) as calculated_amount, 
v.diff::numeric(38,10) as diff,
case when a.opportunity_id is null then 'No' else 'Yes' end::varchar(3) as known_issue,
listagg(isnull(a.issue,'Unknown')::varchar(100) ,'; ')  as known_issue_description,
'{{ var("loaddate") }}'::timestamp as loaddate	
from final_data v
join {{ ref("stg_opportunities_chain_of_renewals") }} socr
on v.opportunity_id = socr.opportunity_id
left join audit as a
    on 
    (
    a.parent_opportunities ilike '%'+v.opportunity_id+'%'
    or
    socr.parent_opportunities ilike '%'+a.opportunity_id+'%'
    )
   where diff!=0 
   group by all
