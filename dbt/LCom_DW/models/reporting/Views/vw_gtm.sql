{{ config(materialized='view', bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]) }}


select
close.mon_year mon_year
,close.mon_lastday mon_lastday
,close.fiscalyear fiscalyear
,close.fiscalyear_mon fiscalyear_mon
--
,ds.created_date
,ds.close_date
,ds.start_date
,ds.end_date
,ds.subscription_term
,coalesce(nullif(ds.Contract_type,'Unknown'),'Not Set') as Contract_type
,case when ds.invoiced_date='1900-01-01' then null else ds.invoiced_date end invoiced_date
,ds.stage_name
,ds.opp_record_type
,ds.opportunity_id
,ds.opportunity_name
,ds.opportunity_number
--
,e.name as opportunity_owner
,eh.name as opportunity_owner_on_deal_close
--
,ds.multi_year_discount_rate
,ds.is_LOI
,coalesce(nullif(ds.EComm,'Unknown'),'Not EComm') as EComm
,c.sfdc_account_id as customer_id
,c.first_invoiced_date as customer_since_date
,ds.account_id
,a.first_invoiced_date as account_customer_since_date
,ds.bucket
,ds.opportunity_line_id
,ds.sfdc_product_id
,ds.nrr
,ds.arr
,ds.quantity
,ds.list_price
,ds.additional_discount_amount
,ds.additional_discount_rate
,case when ds.additional_discount_type='Unknown' then '' else ds.additional_discount_type end as additional_discount_type
,ds.total_discount_amount
,ds.total_discount_rate
--
,p.sfdc_product_name
,p.lcom_suite
,p.sfdc_product_family
,p.sfdc_product_sub_family
--
,a.sfdc_account_id
,a.sfdc_name as account_name
,a.sfdc_billing_country as account_country
,a.sfdc_billing_state as account_state
,a.sfdc_county_name as account_county
,a.sfdc_owner_name_text as account_owner
,ah.sfdc_owner_name_text as account_owner_on_deal_close
,case when a.sfdc_district_enrollment=0 then a.sfdc_school_enrollment else a.sfdc_district_enrollment end as account_enrollment
,case when (a.sfdc_state_initiative or a.sfdc_state_initiative_school) then true else false end as account_state_initiative
,a.sfdc_urban_rural as acount_locale
,a.sfdc_customer_level as account_tier
--
,c.sfdc_account_id sfdc_customer_id
,c.sfdc_name as customer_name
,c.sfdc_billing_country as customer_country
,c.sfdc_billing_state as customer_state
,c.sfdc_county_name as customer_county
,c.sfdc_owner_name_text as customer_owner
,ch.sfdc_owner_name_text as customer_owner_on_deal_close
,case when c.sfdc_district_enrollment=0 then c.sfdc_school_enrollment else c.sfdc_district_enrollment end as customer_enrollment
,case when (c.sfdc_state_initiative or c.sfdc_state_initiative_school) then true else false end as customer_state_initiative
,c.sfdc_urban_rural as customer_locale
,c.sfdc_customer_level as customer_tier
--
from {{ ref("vw_deal") }} ds
join {{ ref("fact_opportunity_history") }} foh
on ds.opportunity_id = foh.opportunity_id
and ds.close_date between foh.fromdate and foh.todate
join {{ ref("dim_account") }} a
on ds.account_id = a.account_id
join {{ ref("dim_account_history") }} ah
on ds.account_id = ah.account_id
and ds.close_date between ah.fromdate and ah.todate
join {{ ref("dim_account") }} c
on a.sfdc_ultimate_parent_id = c.sfdc_account_id
join {{ ref("dim_account_history") }} ch
on c.account_id = ch.account_id
and ds.close_date between ch.fromdate and ch.todate
join {{ ref("dim_sfdc_product") }} p
on ds.sfdc_product_id = p.sfdc_product_id
join {{ ref("dim_calendar") }} close
on close.cal_date = ds.close_date
join {{ ref("dim_employee") }} e
on ds.opportunity_owner_id = e.employee_id
join {{ ref("dim_employee") }} eh
on foh.owner_id = eh.employee_id
where  
/*clean set of deals: closed Won and invoiced or Lost
exclude negative or replacement opportunities */
is_negative_or_replacement = 'No'
and ds.close_date <= current_date
and ((ds.stage_name ilike '%won%' and ds.invoiced_date!='1900-01-01') or ds.stage_name ilike '%lost%')

