create schema audit;
COMMENT on schema licensing is 'The schema is used for log tables and other audit info';

create schema common;
COMMENT on schema common is 'Common schema combines conformed dimensions objects used in more then one business area/schema';

create schema content_delivery_usage;
COMMENT on schema content_delivery_usage is 'Content_Delivery_Usage schema combines fact and dimensions objects related to content delivery and usage. It may content views based on the original sources in content_delivery_usage database dbo or staging objects';

create schema licensing;
COMMENT on schema licensing is 'Licensing schema combines fact and dimensions objects related to Licensing. It may content views based on the original sources in content_delivery_usage database staging objects';

create schema reporting;
COMMENT on schema reporting is 'Reporting schema is for objects (mostly views) created specifically for dashboards, reports, data feeds, etc';

CREATE SCHEMA revenue;
COMMENT on schema revenue is 'Revenue schema combines fact and dimensions objects related to Revenue, Sales and Fimamce.';
