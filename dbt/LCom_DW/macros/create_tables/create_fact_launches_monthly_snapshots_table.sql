{% macro create_fact_launches_monthly_snapshots_table() %}
{% set create_table_operation %}

drop table if exists content_delivery_usage.fact_launches_monthly_snapshots;
CREATE TABLE content_delivery_usage.fact_launches_monthly_snapshots (
    mon_lastday date NOT NULL ENCODE raw,
    organization_district_id character varying(255) NOT NULL ENCODE lzo distkey,
    organization_school_id character varying(255) NOT NULL ENCODE lzo,
    active_students_ytd integer NOT NULL ENCODE az64,
    launches_ytd integer NOT NULL ENCODE az64,
    distinctitemsstudent_ytd integer NOT NULL ENCODE az64,
    active_students_month integer NOT NULL ENCODE az64,
    launches_month integer NOT NULL ENCODE az64,
    distinctitemsstudent_month integer NOT NULL ENCODE az64,
    loaddate timestamp without time zone NOT NULL ENCODE az64
) DISTSTYLE KEY
SORTKEY
    (mon_lastday);
    
   
COMMENT ON TABLE content_delivery_usage.fact_launches_monthly_snapshots IS 'Cumulative activity from the start of a  school year (YTD) till end of month per student aggregated to the school level';

COMMENT ON COLUMN content_delivery_usage.fact_launches_monthly_snapshots.mon_lastday is 'Last day of a month';
COMMENT ON COLUMN content_delivery_usage.fact_launches_monthly_snapshots.organization_district_id is 'Organization.Parent_Organization_ID because content_delivery_usage.dbo.fact_assignment_launch.organization_district_id can be different for the same school in the historical perspective.';
COMMENT ON COLUMN content_delivery_usage.fact_launches_monthly_snapshots.organization_school_id is 'content_delivery_usage.dbo.fact_assignment_launch.organization_school_id';
COMMENT ON COLUMN content_delivery_usage.fact_launches_monthly_snapshots.Active_Students_YTD is 'Unique number of students for a specific school since the start of a current school year till end of a month';
COMMENT ON COLUMN content_delivery_usage.fact_launches_monthly_snapshots.Launches_YTD is 'Number of launches from a specific school since the start of a current school year till end of a month';
COMMENT ON COLUMN content_delivery_usage.fact_launches_monthly_snapshots.DistinctItemsStudent_YTD is 'Unique number of curriculum items loaded by user since the start of a current school year till end of a month and summarized at the school level';
COMMENT ON COLUMN content_delivery_usage.fact_launches_monthly_snapshots.Active_Students_month is 'Difference between current and previous month Active_Students_YTD';
COMMENT ON COLUMN content_delivery_usage.fact_launches_monthly_snapshots.Launches_month is 'Difference between current and previous month Launches_YTD';
COMMENT ON COLUMN content_delivery_usage.fact_launches_monthly_snapshots.DistinctItemsStudent_month is 'Difference between current and previous month DistinctItemsStudent_YTD';






{% endset %}

{% do run_query(create_table_operation) %}

{% endmacro %} 