{% macro create_fact_launches_weekly_snapshots_table() %}

{% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %}

 {% if flags.WHICH in ('run','build') %}
  {% set custom_schema = model.config.schema | default(target.schema, true) %}
 {% else %}
  {% set custom_schema = target.schema %}
 {% endif %}

{{ log('Creating fact_launches_weekly_snapshots table in schema ' ~ custom_schema, info=True) }}

{% set create_table_operation %}

CREATE TABLE IF NOT EXISTS {{target.database}}.{{custom_schema}}.fact_launches_weekly_snapshots
(
WeekEnd date not null,
organization_district_id varchar(255) not null,
organization_school_id varchar(255) not null,
Active_Students_YTD integer not null,
Launches_YTD integer not null,
DistinctItemsStudent_YTD integer not null,
--
Active_Students_Week integer not null,
Launches_Week integer not null,
DistinctItemsStudent_Week integer not null,
--
LoadDate timestamp not null
)
DISTSTYLE KEY
 DISTKEY (organization_district_id)
 SORTKEY (
	WeekEnd
	)
;



COMMENT ON TABLE {{target.database}}.{{custom_schema}}.fact_launches_weekly_snapshots IS 'Cumulative activity from the start of a  school year (YTD) till week end (Sunday) per student aggregated to the school level';

COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_launches_weekly_snapshots.WeekEnd is 'Sunday';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_launches_weekly_snapshots.organization_district_id is 'Organization.Parent_Organization_ID because content_delivery_usage.dbo.fact_assignment_launch.organization_district_id can be different for the same school in the historical perspective.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_launches_weekly_snapshots.organization_school_id is 'content_delivery_usage.dbo.fact_assignment_launch.organization_school_id';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_launches_weekly_snapshots.Active_Students_YTD is 'Unique number of students for a specific school since the start of a current school year till WeekEnd';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_launches_weekly_snapshots.Launches_YTD is 'Number of launches from a specific school since the start of a current school year till WeekEnd';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_launches_weekly_snapshots.DistinctItemsStudent_YTD is 'Unique number of curriculum items loaded by user since the start of a current school year till WeekEnd and summarized at the school level';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_launches_weekly_snapshots.Active_Students_Week is 'Difference between current and previous week Active_Students_YTD';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_launches_weekly_snapshots.Launches_Week is 'Difference between current and previous week Launches_YTD';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_launches_weekly_snapshots.DistinctItemsStudent_Week is 'Difference between current and previous week DistinctItemsStudent_YTD';






{% endset %}

{% do run_query(create_table_operation) %}

{% endif %}

{% endmacro %} 