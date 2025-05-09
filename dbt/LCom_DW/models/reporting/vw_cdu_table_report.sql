{{ config(materialized='view', bind=False) }}

--row count and last action date for all tables/views in content_delivery_usage
with table_report as (
--dbo 
select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'content_instruction_type' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)), 
		--(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
				)) as last_action_date
from content_delivery_usage.dbo.content_instruction_type
 
union all

select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'content_subtopic' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)), 
		--(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
				)) as last_action_date
from content_delivery_usage.dbo.content_subtopic

union all

select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'content_topic' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)), 
		--(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
				)) as last_action_date
from content_delivery_usage.dbo.content_topic

union all

select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'context' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)), 
		(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
				)) as last_action_date
from content_delivery_usage.dbo.context

union all

select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'context_assignment' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(assignment_start_date as date))
				)) as  last_action_date
from content_delivery_usage.dbo.context_assignment

union all

select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'context_enrollment' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(enrollment_start_date as date))
				)) as  last_action_date
from content_delivery_usage.dbo.context_enrollment

union all

select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'fact_assignment_completion' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)), 
		(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
				)) as last_action_date
from content_delivery_usage.dbo.fact_assignment_completion

union all

select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'fact_assignment_launch' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		--(cast(created_datetime as date)), 
		--(cast(modified_datetime as date)), 
		--(cast(deleted_datetime as date))
		(cast(launch_datetime as date))
				)) as last_action_date
from content_delivery_usage.dbo.fact_assignment_launch

union all

select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'learning_object' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)), 
		--(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
				)) as last_action_date
from content_delivery_usage.dbo.learning_object

union all

select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'learning_pathway' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)), 
		--(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
				)) as last_action_date
from content_delivery_usage.dbo.learning_pathway

union all

--skipping mv_tbl__mv_school__0 and related tables because I got a permission denied error for them

select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'organization' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)), 
		(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
				)) as last_action_date
from content_delivery_usage.dbo.organization

union all

select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'school_enrollment' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(enrollment_start_date as date))
				)) as  last_action_date
from content_delivery_usage.dbo.school_enrollment

union all

select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'table_record_count' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(updated_at as date))
		--(cast(created_datetime as date)), 
		--(cast(modified_datetime as date)), 
		--(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
				)) as last_action_date
from content_delivery_usage.dbo.table_record_count

union all

select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'user_account' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)), 
		(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
				)) as last_action_date
from content_delivery_usage.dbo.user_account

union all

select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'mv_school' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)), 
		(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
				)) as last_action_date
from content_delivery_usage.dbo.mv_school

union all

select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'mv_student_account' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)), 
		(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
				)) as last_action_date
from content_delivery_usage.dbo.mv_student_account

union all

select
	'content_delivery_usage' as database_name
	,'dbo' as schema_name
	,'mv_teacher_account' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)), 
		(cast(modified_datetime as date)), 
		(cast(deleted_datetime as date))
		--(cast(launch_datetime as date))
				)) as last_action_date
from content_delivery_usage.dbo.mv_teacher_account

--staging
union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'context_assignment' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(assignment_start_date as date))
				)) as last_action_date
from content_delivery_usage.staging.context_assignment

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'context_cds' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)),
		(cast(modified_datetime as date)),
		(cast(deleted_datetime as date))
				)) as last_action_date
from content_delivery_usage.staging.context_cds

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'context_enrollment' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(enrollment_start_date as date))
				)) as last_action_date
from content_delivery_usage.staging.context_enrollment

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'context_platform' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)),
		(cast(modified_datetime as date)),
		(cast(deleted_datetime as date))
				)) as last_action_date
from content_delivery_usage.staging.context_platform

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'event' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(score_datetime as date))
				)) as last_action_date
from content_delivery_usage.staging.event

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'fact_assignment_completion' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(score_datetime as date))
				)) as last_action_date
from content_delivery_usage.staging.fact_assignment_completion

/*union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'fact_assignment_launch' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(launch_datetime as date))
				)) as last_action_date
from content_delivery_usage.staging.fact_assignment_launch*/

--omitting launch_from_csv table because the timestamp column is in varchar format and can't be cast as a date

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'learning_object' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)),
		(cast(modified_datetime as date))
				)) as last_action_date
from content_delivery_usage.staging.learning_object

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'learning_object_standard' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date))
				)) as last_action_date
from content_delivery_usage.staging.learning_object_standard

union all

--ommitting learning_pathway_object because it does not have a datestamp and is likely a static table

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'license_order' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from content_delivery_usage.staging.license_order

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'license_orderschool' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from content_delivery_usage.staging.license_orderschool

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'sku' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from content_delivery_usage.staging.sku

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'sku_suite' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from content_delivery_usage.staging.sku_suite
union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'sku_learning_object_v2' as table_name
	,COUNT(*) as row_count
	,MAX(loaddate) as last_action_date
from content_delivery_usage.staging.sku_learning_object_v2

--ommitting map_roles and map_state_province_code, look like static tables without timestamps

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'org_district' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)),
		(cast(auditupdatedate as date)),
		(cast(modified_datetime as date))
				)) as last_action_date
from content_delivery_usage.staging.org_district

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'org_school' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)),
		(cast(auditupdatedate as date)),
		(cast(modified_datetime as date))
				)) as last_action_date
from content_delivery_usage.staging.org_school

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'school_enrollment' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(enrollment_start_date as date))
				)) as last_action_date
from content_delivery_usage.staging.school_enrollment

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'school_enrollment_cds' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(audit_create_date as date)),
		(cast(audit_update_date as date))
				)) as last_action_date
from content_delivery_usage.staging.school_enrollment_cds

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'school_enrollment_refresh' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(enrollment_start_date as date))
				)) as last_action_date
from content_delivery_usage.staging.school_enrollment_refresh

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'school_enrollment_reload' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(enrollment_start_date as date))
				)) as last_action_date
from content_delivery_usage.staging.school_enrollment_reload

--ommitting skill, sku_learning_object, standard - static table w/o timestamp

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'user_account_cds' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)),
		(cast(modified_datetime as date)),
		(cast(deleted_datetime as date))
				)) as last_action_date
from content_delivery_usage.staging.user_account_cds

union all

select
	'content_delivery_usage' as database_name
	,'staging' as schema_name
	,'user_account_platform' as table_name
	,COUNT(*) as row_count
	,MAX(greatest(
		(cast(created_datetime as date)),
		(cast(modified_datetime as date)),
		(cast(deleted_datetime as date))
				)) as last_action_date
from content_delivery_usage.staging.user_account_platform

) 

select
	*
	--days elapsed since last action
	,DATEDIFF(day, table_report.last_action_date, cast(CURRENT_TIMESTAMP as date)) as days_since_last_action
	from table_report
order by table_report.last_action_date