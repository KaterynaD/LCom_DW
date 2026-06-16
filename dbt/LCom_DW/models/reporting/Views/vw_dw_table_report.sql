{{ config(materialized='view', bind=False) }}

--row count and last action date for all tables/views in dw
with table_report as (
--common

select
	'dw' as database_name
	,'common' as schema_name
	,'dim_account' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.common.dim_account
union all



select
	'dw' as database_name
	,'common' as schema_name
	,'dim_lcom_sku' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.common.dim_lcom_sku
union all

select
	'dw' as database_name
	,'common' as schema_name
	,'dim_lcom_suite' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.common.dim_lcom_suite
union all

select
	'dw' as database_name
	,'common' as schema_name
	,'dim_lcom_suite_sku' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.common.dim_lcom_suite_sku




union all

select
	'dw' as database_name
	,'common' as schema_name
	,'dim_sfdc_product' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.common.dim_sfdc_product

union all

select
	'dw' as database_name
	,'common' as schema_name
	,'dim_employee' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.common.dim_employee

union all

select
	'dw' as database_name
	,'common' as schema_name
	,'dim_contact' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.common.dim_contact

union all

select
	'dw' as database_name
	,'common' as schema_name
	,'dim_employee_history' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.common.dim_employee_history

union all

select
	'dw' as database_name
	,'common' as schema_name
	,'dim_contact_history' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.common.dim_contact_history
union all

select
	'dw' as database_name
	,'common' as schema_name
	,'dim_account_history' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.common.dim_account_history
union all


--content_delivery_usage


select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'dim_learning_object' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.content_delivery_usage.dim_learning_object



union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'fact_launches_monthly_snapshots' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(cast(loaddate as date))) as last_action_date
from dw.content_delivery_usage.fact_launches_monthly_snapshots

union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'fact_launches_weekly_snapshots' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(cast(loaddate as date))) as last_action_date
from dw.content_delivery_usage.fact_launches_weekly_snapshots

union all
select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'dim_lcom_sku_learning_object' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.content_delivery_usage.dim_lcom_sku_learning_object


union all
select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'dim_sequence' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.content_delivery_usage.dim_sequence


union all
select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'dim_sequence_learning_object' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.content_delivery_usage.dim_sequence_learning_object

union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'fact_students_usage_monthly_snapshots' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.content_delivery_usage.fact_students_usage_monthly_snapshots

union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'fact_students_completions_monthly_snapshots' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.content_delivery_usage.fact_students_completions_monthly_snapshots

union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'dim_product_category_learning_object_monthly' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.content_delivery_usage.dim_product_category_learning_object_monthly

union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'dim_product_category' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.content_delivery_usage.dim_product_category

union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'dim_training_session_topic' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.content_delivery_usage.dim_training_session_topic

union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'dim_training_session_topic_session' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.content_delivery_usage.dim_training_session_topic_session

union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'fact_enrollment_monthly_snapshots' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.content_delivery_usage.fact_enrollment_monthly_snapshots

union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'fact_skillscheck_calendaryear_snapshots' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.content_delivery_usage.fact_skillscheck_calendaryear_snapshots

union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'fact_skillscheck_schoolyear_snapshots' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.content_delivery_usage.fact_skillscheck_schoolyear_snapshots

union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'fact_training_session' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.content_delivery_usage.fact_training_session

union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'fact_training_session_history' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.content_delivery_usage.fact_training_session_history


--marketing

union all

select
	'dw' as database_name
	,'marketing' as schema_name
	,'dim_campaign' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.marketing.dim_campaign

union all

select
	'dw' as database_name
	,'marketing' as schema_name
	,'fact_contact_lifecycle_events' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.marketing.fact_contact_lifecycle_events


--revenue

union all

select
	'dw' as database_name
	,'revenue' as schema_name
	,'fact_opportunity' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.revenue.fact_opportunity


union all

select
	'dw' as database_name
	,'revenue' as schema_name
	,'fact_opportunity_history' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.revenue.fact_opportunity_history

union all

select
	'dw' as database_name
	,'revenue' as schema_name
	,'dim_opportunity_line' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.revenue.dim_opportunity_line

union all

select
	'dw' as database_name
	,'revenue' as schema_name
	,'dim_opportunity_line_history' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.revenue.dim_opportunity_line_history

union all

select
	'dw' as database_name
	,'revenue' as schema_name
	,'fact_paying_customers' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.revenue.fact_paying_customers

union all

select
	'dw' as database_name
	,'revenue' as schema_name
	,'fact_revenue_monthly_snapshots' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.revenue.fact_revenue_monthly_snapshots

union all

select
	'dw' as database_name
	,'revenue' as schema_name
	,'dim_arr_audit' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.revenue.dim_arr_audit

union all

select
	'dw' as database_name
	,'revenue' as schema_name
	,'dim_arr_issue' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.revenue.dim_arr_issue

union all

select
	'dw' as database_name
	,'revenue' as schema_name
	,'dim_arr_validation' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.revenue.dim_arr_validation

union all

select
	'dw' as database_name
	,'revenue' as schema_name
	,'fact_arr' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.revenue.fact_arr

union all

select
	'dw' as database_name
	,'revenue' as schema_name
	,'fact_booking' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.revenue.fact_booking

union all

select
	'dw' as database_name
	,'revenue' as schema_name
	,'fact_customer' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.revenue.fact_customer

union all

select
	'dw' as database_name
	,'revenue' as schema_name
	,'netsuite_ch042808' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.revenue.netsuite_ch042808

union all

select
	'dw' as database_name
	,'revenue' as schema_name
	,'hubspot_deal' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.revenue.hubspot_deal


--licensing

union all

select
	'dw' as database_name
	,'licensing' as schema_name
	,'fact_license_order' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.licensing.fact_license_order

union all

select
	'dw' as database_name
	,'licensing' as schema_name
	,'fact_license_order_history' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.licensing.fact_license_order_history

union all

select
	'dw' as database_name
	,'licensing' as schema_name
	,'dim_license_order_school' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.licensing.dim_license_order_school

--support
union all

select
	'dw' as database_name
	,'support' as schema_name
	,'fact_case' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.support.fact_case

union all

select
	'dw' as database_name
	,'support' as schema_name
	,'fact_case_history' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from dw.support.fact_case_history

) 

select
	*
	--days elapsed since last action
	,DATEDIFF(day, table_report.last_action_date, cast(CURRENT_TIMESTAMP as date)) as days_since_last_action
	from table_report
order by table_report.last_action_date