create schema profiles_salesforce_quickstart;
COMMENT on schema profiles_salesforce_quickstart is 'The schema contains tables profiles from fivetran_salesforce_quickstart schema. Populated via dbt transformations';

select table_name, count(column_name) cnt_columns      
from information_schema.columns
where table_schema = 'fivetran_salesforce_quickstart'
group by table_name 
order by cnt_columns desc;
