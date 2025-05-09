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
from common.dim_account


union all

select
	'dw' as database_name
	,'common' as schema_name
	,'dim_student' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)), 
		(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
				)) as last_action_date
from common.dim_student


union all

select
	'dw' as database_name
	,'common' as schema_name
	,'dim_teacher' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)), 
		(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
				)) as last_action_date
from common.dim_teacher


union all

select
	'dw' as database_name
	,'common' as schema_name
	,'dim_user' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
	--different naming scheme for timestamps
		(cast(lcom_created_datetime as date)), 
		(cast(lcom_modified_datetime as date)), 
		(cast(lcom_deleted_datetime as date))
		--(cast(launch_datetime as date))
				)) as last_action_date
from common.dim_user

union all



select
	'dw' as database_name
	,'common' as schema_name
	,'dim_lcom_sku' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from common.dim_lcom_sku
union all

select
	'dw' as database_name
	,'common' as schema_name
	,'dim_lcom_suite' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from common.dim_lcom_suite
union all

select
	'dw' as database_name
	,'common' as schema_name
	,'dim_lcom_suite_sku' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from common.dim_lcom_suite_sku
union all
select
	'dw' as database_name
	,'common' as schema_name
	,'dim_sfdc_product' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from common.dim_sfdc_product

union all


--content_delivery_usage

	select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'dim_context' as table_name
	,COUNT(*) as row_count
	,MAX(greatest((
		cast(created_datetime as date)), 
		(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
			)) as last_action_date
from content_delivery_usage.dim_context

union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'dim_learning_object' as table_name
	,COUNT(*) as row_count
	,MAX(greatest((
		cast(created_datetime as date)), 
		--(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
		)) as last_action_date
from content_delivery_usage.dim_learning_object


--excluding table dim_learning_pathway - was a one-time action added at beginning of COVID, no longer used


union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'fact_assignment_completion' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)), 
		(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
		)) as last_action_date
from content_delivery_usage.fact_assignment_completion

union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'fact_assignment_launch' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		--(cast(created_datetime as date)), 
		--(cast(modified_datetime as date)), 
		--(cast(deleted_datetime as date))),
		(cast(launch_datetime as date))
				)) as last_action_date
from content_delivery_usage.fact_assignment_launch

union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'fact_launches_monthly_snapshots' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(cast(loaddate as date))) as last_action_date
from content_delivery_usage.fact_launches_monthly_snapshots

union all

select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'fact_launches_weekly_snapshots' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(cast(loaddate as date))) as last_action_date
from content_delivery_usage.fact_launches_weekly_snapshots

union all
select
	'dw' as database_name
	,'content_delivery_usage' as schema_name
	,'dim_lcom_sku_learning_object' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from content_delivery_usage.dim_lcom_sku_learning_object

--revenue

union all

select
	'dw' as database_name
	,'revenue' as schema_name
	,'fact_opportunity' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from revenue.fact_opportunity


union all

select
	'dw' as database_name
	,'revenue' as schema_name
	,'fact_opportunity_history' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from revenue.fact_opportunity_history

--licensing

union all

select
	'dw' as database_name
	,'licensing' as schema_name
	,'fact_license_order' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from licensing.fact_license_order

union all

select
	'dw' as database_name
	,'licensing' as schema_name
	,'fact_license_order_history' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from licensing.fact_license_order_history

union all

select
	'dw' as database_name
	,'licensing' as schema_name
	,'dim_license_order_school' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from licensing.dim_license_order_school

union all



select
	'dw' as database_name
	,'common' as schema_name
	,'dim_lcom_sku' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from common.dim_lcom_sku
union all

select
	'dw' as database_name
	,'common' as schema_name
	,'dim_lcom_suite' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from common.dim_lcom_suite
union all

select
	'dw' as database_name
	,'common' as schema_name
	,'dim_lcom_suite_sku' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from common.dim_lcom_suite_sku
union all
select
	'dw' as database_name
	,'common' as schema_name
	,'dim_sfdc_product' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from common.dim_sfdc_product
) 

select
	*
	--days elapsed since last action
	,DATEDIFF(day, table_report.last_action_date, cast(CURRENT_TIMESTAMP as date)) as days_since_last_action
	from table_report
order by table_report.last_action_date