{% macro create_schemas() %}
 {% set create_schemas_operation %}

create schema audit;
COMMENT on schema audit is 'The schema is used for log tables and other audit info';

create schema common;
COMMENT on schema common is 'Common schema combines conformed dimensions objects used in more then one business area/schema';

create schema content_delivery_usage;
COMMENT on schema content_delivery_usage is 'Content_Delivery_Usage schema combines fact and dimensions objects related to content delivery and usage. It may content views based on the original sources in content_delivery_usage database dbo or staging objects';

create schema licensing;
COMMENT on schema licensing is 'Licensing schema combines fact and dimensions objects related to Licensing. It may content views based on the original sources in content_delivery_usage database staging objects';

create schema marketing;
COMMENT on schema marketing is 'Marketing schema is for campaigns and other objects related to marketing reporting ';

create schema reporting;
COMMENT on schema reporting is 'Reporting schema is for objects (mostly views) created specifically for dashboards, reports, data feeds, etc';

create schema revenue;
COMMENT on schema revenue is 'Revenue schema is for fact and dimensions objects related to revenue.';

create schema staging;
COMMENT on schema staging is 'Staging schema is for staging and intermediate dbt models';

create schema support;
COMMENT on schema support is 'Support schema is for support cases, biz ops tickets ';

{% endset %}

{% do run_query(create_schemas_operation) %}

{% endmacro %} 