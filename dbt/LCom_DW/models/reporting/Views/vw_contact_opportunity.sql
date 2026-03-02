{{ config(materialized='view', bind=False) }}

with opp_contact_id as (
select
opportunity_id,
contact_id
from {{ ref("fact_opportunity") }} fo
union all
SELECT
opportunity_id,
x_1_st_contact as contact_id
from {{ ref("fact_opportunity") }} fo
union all
SELECT
opportunity_id,
x_2_nd_contact as contact_id
from {{ ref("fact_opportunity") }} fo
union all
SELECT
opportunity_id,
x_3_rd_contact as contact_id
from {{ ref("fact_opportunity") }} fo),
opp_contact as --get rid of repeat contacts (e.g. contacts that are primary and 1st contact for same opp)
(select
opportunity_id,
contact_id,
count(*) as contact_dupe_count
from opp_contact_id
where contact_id <> '{{ var("default_ID") }}' --exclude placeholder for missing contacts
group by opportunity_id, contact_id),
contact_opp_ranks as (
select
    oc.contact_id,
    oc.opportunity_id,
    o.created_date,
    (select count(*)
     from opp_contact oc2
     join {{ ref("fact_opportunity") }} o2 on oc2.opportunity_id = o2.opportunity_id
     where oc2.contact_id = oc.contact_id
     and (o2.created_date < o.created_date
          or (o2.created_date = o.created_date and oc2.opportunity_id <= oc.opportunity_id))
    ) as opportunity_order,
    (select min(o2.created_date)
     from opp_contact oc2
     join {{ ref("fact_opportunity") }} o2 on oc2.opportunity_id = o2.opportunity_id
     where oc2.contact_id = oc.contact_id
    ) as first_opp_date,
    (select max(o2.created_date)
     from opp_contact oc2
     join {{ ref("fact_opportunity") }} o2 on oc2.opportunity_id = o2.opportunity_id
     where oc2.contact_id = oc.contact_id
    ) as latest_opp_date
from opp_contact oc
join {{ ref("fact_opportunity") }} o on oc.opportunity_id = o.opportunity_id
),
contact_mql_dates as (
select
    contact_id,
    min(lead_stage_date_unified) as contact_mql_date
from {{ ref("fact_contact_lifecycle_events") }}
where lead_stage_historic = 'MQL' 
  and lead_stage_date_unified is not null
group by contact_id
),
contact_sql_dates as (
select
    contact_id,
    min(lead_stage_date_unified) as contact_sql_date 
from {{ ref("fact_contact_lifecycle_events") }}
where lead_stage_historic = 'SQL' 
  and lead_stage_date_unified is not null
group by contact_id
),
-- Get all opportunities (base for the query)
all_opportunities as (
select distinct opportunity_id
from {{ ref("fact_opportunity") }}
)
select
	coalesce(oc.contact_id, '{{ var("default_ID") }}') as contact_id,
	c.name as contact_name,
	case when coalesce(oc.contact_id, '{{ var("default_ID") }}') = '{{ var("default_ID") }}' then false else true end as opp_has_contact,
	ao.opportunity_id,
	o.name as opportunity_name,
	--opportunity order and flags
	cor.opportunity_order,
	case when o.created_date = cor.first_opp_date then true else false end as is_first_opportunity,
	case when o.created_date = cor.latest_opp_date then true else false end as is_latest_opportunity,
	--opportunity details
	o.opp_record_type,
	o.stage_name as opp_stage_name,
	case when o.stage_name ilike '%Closed%' then true else false end as is_closed,
	case when o.stage_name ilike '%Won%' or o.invoiced_date > '1900-01-01' then true else false end as is_won,
	--account details
		o.sfdc_account_id as opp_account_id,
		da.lcom_organization_name as account_org_name,
		da.lcom_organization_type as account_org_type,
	da.sfdc_billing_state as account_state,
	da.sfdc_billing_state_code as account_state_code,
	--campaign details
	o.campaign_id,
	dc.name as campaign_name,
	dc.campaign_type,
	dc.campaign_status,
	dc.description as campaign_description,
	dc.created_date as campaign_created_date,
	dc.start_date as campaign_start_date,
	dc.end_date as campaign_end_date,
	dc.owner_id as campaign_owner_id,
	dc.owner_name as campaign_owner_name,
	--contact dates and details to avoid joining in tableau because it's being a beast about it
	c.lead_status as contact_current_lead_stage,
	c.mql_type as contact_origin,
	cmd.contact_mql_date, 
	csd.contact_sql_date,
	--opp dates
	o.created_date as opp_created_date,
	cal.schoolyear as opp_created_schoolyear,
	o.close_date as opp_close_date,
	cal2.schoolyear as opp_close_schoolyear,
	o.invoiced_date as opp_invoiced_date,
	o.paid_date as opp_paid_date,
	o.churn_date as opp_churn_date,
	o.start_date as opp_start_date,
	o.end_date as opp_end_date,
	--opp amount
	o.amount,
	o.amount_won,
	o.arr,
	o.true_arr,
	--opp notes and extras
	o.loss_reason,
	o.loss_notes
from all_opportunities ao
	join {{ ref("fact_opportunity") }} o
		on ao.opportunity_id = o.opportunity_id
	left join opp_contact oc
		on ao.opportunity_id = oc.opportunity_id
	left join contact_opp_ranks cor
		on oc.contact_id = cor.contact_id
		and oc.opportunity_id = cor.opportunity_id
	left join {{ ref("dim_account") }} da
		on o.sfdc_account_id = da.sfdc_account_id
	left join {{ ref("dim_contact") }} c
		on oc.contact_id = c.contact_id
	left join {{ ref("dim_campaign") }} dc
		on o.campaign_id = dc.campaign_id
	left join {{ source("common","dim_calendar") }} cal
		on o.created_date::DATE = cal.cal_date
	left join {{ source("common","dim_calendar") }} cal2
		on o.close_date::DATE = cal2.cal_date
	left join contact_mql_dates cmd
		on oc.contact_id = cmd.contact_id
	left join contact_sql_dates csd
		on oc.contact_id = csd.contact_id
