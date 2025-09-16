{{ config(materialized='view',
   bind=False
)
 }}


with	
Starting as (	
--Before 202507 Expected is based on Active June 30
select	
frms.fiscalyear,
listagg(frms.opportunity_id, ',') parent_opportunities,	
frms.renewal_opportunity_id,	
listagg(frms.bucket + case when frms.include_flg=true then ' ('+frms.opportunity_id+': $' + to_char(round(frms.amount,2), 'FM999,999,990.00')+' included, audit:' + frms.audit_id +')' else ' ('+frms.opportunity_id+': $' + to_char(round(frms.amount,2), 'FM999,999,990.00')+' not included, audit:' + frms.audit_id +')' end, ',')  bucket,	
sum(frms.amount)  total_amount	
from {{ ref("fact_revenue_monthly_snapshots") }} frms	
--flagging upsells added together with renewal	
left outer join {{ ref("fact_revenue_monthly_snapshots") }} frms_renewals	
on frms.opportunity_id = frms_renewals.opportunity_id	
and frms.mon_year=frms_renewals.mon_year	
and frms_renewals.record_type!='MonthlyBooking'	
and frms_renewals.bucket in (	
'Sales : Upsell : ARR',	
'Sales : Upsell : Biz Dev',	
'Sales : Renewal : ARR',	
'Sales : Renewal : Biz Dev')	
and frms.bucket!=frms_renewals.bucket
and frms_renewals.mon_year<202507
--	
where   frms.record_type!='MonthlyBooking'	
and ((frms.bucket in (	
'Expected',	
'Sales : New Business : Biz Dev',	
'Sales : New Business : ARR',	
'Sales : Upsell : ARR',	
'Sales : Upsell : Biz Dev')	
and frms.include_flg = true	
)	
or	
(frms.bucket in (	
'Sales : Renewal : ARR',	
'Sales : Renewal : Biz Dev')	
and frms.include_flg = false	
and frms_renewals.opportunity_id is not null)	
or	
(frms.bucket in (	
'Sales : Renewal : ARR',	
'Sales : Renewal : Biz Dev')	
--and frms.include_flg = true	
and frms_renewals.opportunity_id is null)
)	
and frms.renewal_opportunity_id!='Unknown'
and frms.mon_year<202507
group by
frms.fiscalyear,
frms.renewal_opportunity_id
--
--Starting 202507 - Expected based on Active renewals
--
union all
select
frms.fiscalyear,
listagg(frms.opportunity_id, ',') parent_opportunities,
frms.opportunity_id renewal_opportunity_id,
listagg(frms.bucket + case when frms.include_flg=true then ' ('+frms.opportunity_id+': $' + to_char(round(frms.amount,2), 'FM999,999,990.00') +' - included, audit:' + frms.audit_id +')' else ' ('+frms.opportunity_id+': $' + to_char(round(frms.amount,2), 'FM999,999,990.00') +' not included, audit:' + frms.audit_id +')' end, ',') bucket,
sum(frms.amount) total_amount
from {{ ref("fact_revenue_monthly_snapshots") }} frms
--
where frms.record_type!='MonthlyBooking'
and frms.bucket = 'Expected'
and frms.mon_year>=202507
group by
frms.fiscalyear,
frms.opportunity_id
--
--
union all
--
select
frms.fiscalyear,
listagg(frms.opportunity_id, ',') parent_opportunities,
frms.renewal_opportunity_id,
listagg(frms.bucket + case when frms.include_flg=true then ' ('+frms.opportunity_id+': $' + to_char(round(frms.amount,2), 'FM999,999,990.00') +' - included, audit:' + frms.audit_id +')' else ' ('+frms.opportunity_id+': $' +  to_char(round(frms.amount,2), 'FM999,999,990.00') +' not included, audit:' + frms.audit_id +')' end, ',')  bucket,
sum(frms.amount)  total_amount
from {{ ref("fact_revenue_monthly_snapshots") }} frms
--flagging upsells added together with renewal
left outer join {{ ref("fact_revenue_monthly_snapshots") }} frms_renewals
on frms.opportunity_id = frms_renewals.opportunity_id
and frms.mon_year=frms_renewals.mon_year
and frms_renewals.record_type!='MonthlyBooking'
and frms_renewals.bucket in (
'Sales : Upsell : ARR',
'Sales : Upsell : Biz Dev',
'Sales : Renewal : ARR',
'Sales : Renewal : Biz Dev')
and frms.bucket!=frms_renewals.bucket
and frms_renewals.mon_year>=202507
--
where  frms.record_type!='MonthlyBooking'
and ((frms.bucket in (
'Sales : New Business : Biz Dev',
'Sales : New Business : ARR',
'Sales : Upsell : ARR',
'Sales : Upsell : Biz Dev')
and frms.include_flg = true
)
or
(frms.bucket in (
'Sales : Renewal : ARR',
'Sales : Renewal : Biz Dev')
and frms.include_flg = false
and frms_renewals.opportunity_id is not null)
or
(frms.bucket in (
'Sales : Renewal : ARR',
'Sales : Renewal : Biz Dev')
and frms_renewals.opportunity_id is null)
)
and frms.renewal_opportunity_id!='Unknown'
and frms.mon_year>=202507
group by
frms.fiscalyear,
frms.renewal_opportunity_id
)
--
,Changed as (	
select	
frms.fiscalyear,
frms.bucket,	
frms.opportunity_id,	
frms.renewal_opportunity_id,	
sum(amount) amount	
from {{ ref("fact_revenue_monthly_snapshots") }} frms	
where  record_type!='MonthlyBooking'	
and bucket in (	
'Sales : Price Increased : ARR',	
'Sales : Price Increased : Biz Dev',	
'Sales : Reduction : ARR',	
'Sales : Reduction : Biz Dev',	
'Sales : Cancellation : ARR',	
'Sales : Cancellation : Biz Dev')	
and frms.include_flg = true	
group by	
frms.fiscalyear,
frms.bucket,	
frms.opportunity_id,	
frms.renewal_opportunity_id	
)	
,Actual as (	
select	
frms.fiscalyear,
frms.bucket,	
frms.opportunity_id,	
frms.renewal_opportunity_id,	
sum(amount) amount	
from {{ ref("fact_revenue_monthly_snapshots") }} frms	
where record_type!='MonthlyBooking'	
and bucket in (	
'Sales : Renewal : ARR',	
'Sales : Renewal : Biz Dev')	
and frms.include_flg = false	
group by
frms.fiscalyear,
frms.bucket,	
frms.opportunity_id,	
frms.renewal_opportunity_id	
)	
,details as (
select
o.opportunity_id,
o.name opportunity_name,
o.opportunity_number,
up.sfdc_account_id ultimate_parent_account_id,
up.sfdc_name ultimate_parent_account_name
 from {{ ref('fact_opportunity') }} o
 join {{ ref('dim_account') }} ca
 on o.account_id = ca.account_id
 join {{ ref('dim_account') }} up
 on ca.sfdc_ultimate_parent_id = up.sfdc_account_id
)
,diff_data as (	
select	
s.fiscalyear,
s.bucket starting_bucket,	
s.parent_opportunities starting_opportunities,
s.total_amount starting_amount,	
c.bucket changed_bucket,	
c.opportunity_id changed_opportunity_id,	
isnull(c.amount,0) changed_amount,	
case when a.bucket is null and c.bucket ilike '%Cancellation%' then c.bucket else isnull(a.bucket,'No related ARR Renewal') end actual_bucket,	
case when a.bucket is null and c.bucket ilike '%Cancellation%' then c.opportunity_id else a.opportunity_id end actual_opportunity_id,
isnull(a.amount,0) actual_amount,	
starting_amount + isnull(changed_amount,0) ARR,	
case when c.bucket is not null then actual_amount - ARR else 0 end diff	
from Starting s	
left outer join Changed c	
on s.renewal_opportunity_id = c.opportunity_id	
and s.fiscalyear = c.fiscalyear
left outer join Actual a	
on s.renewal_opportunity_id = a.opportunity_id	
and s.fiscalyear = a.fiscalyear
)	
,final_data as (
select 
dd.fiscalyear,
dd.starting_bucket,	
dd.starting_opportunities,	
dd.starting_amount,	
--
co.ultimate_parent_account_id changed_ultimate_parent_account_id,
co.ultimate_parent_account_name changed_ultimate_parent_account_name,
dd.changed_bucket,	
dd.changed_opportunity_id,	
co.opportunity_name changed_opportunity_name,
co.opportunity_number changed_opportunity_number,
dd.changed_amount,	
--
ao.ultimate_parent_account_id actual_ultimate_parent_account_id,
ao.ultimate_parent_account_name actual_ultimate_parent_account_name,
dd.actual_bucket,	
dd.actual_opportunity_id,
ao.opportunity_name actual_opportunity_name,
ao.opportunity_number actual_opportunity_number,
dd.actual_amount,	
--
dd.ARR,	
dd.diff
from diff_data	dd
--
--
left outer join details co
on dd.changed_opportunity_id = co.opportunity_id
--
left outer join details ao
on isnull(dd.actual_opportunity_id,dd.changed_opportunity_id) = ao.opportunity_id
--
)
select 
fiscalyear,
starting_bucket,	
starting_opportunities,	
starting_amount,	
changed_ultimate_parent_account_id,
changed_ultimate_parent_account_name,
changed_bucket,	
changed_opportunity_id,	
changed_opportunity_name,
changed_opportunity_number,
changed_amount,	
--
actual_ultimate_parent_account_id,
actual_ultimate_parent_account_name,
actual_bucket,	
actual_opportunity_id,
actual_opportunity_name,
actual_opportunity_number,
actual_amount,	
--
ARR,	
diff
from final_data