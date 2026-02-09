with b as (select table_name, max(loaddate) loaddate, count(column_name) columns_cnt
from {{ source("profiles","vw_sfdc_schema_audit") }} a
where profile_name='base'
group by table_name)
,c as (select table_name, max(loaddate) loaddate, count(column_name) columns_cnt
from {{ source("profiles","vw_sfdc_schema_audit") }} a
where profile_name='current'
group by table_name)
select
coalesce(b.table_name,c.table_name) table_name, 
b.loaddate base_profile_loaddate, 
b.columns_cnt base_profile_columns_cnt,   
c.loaddate current_profile_loaddate, 
c.columns_cnt current_profile_columns_cnt,
b.columns_cnt - c.columns_cnt Difference
from b
full outer join c
on b.table_name=c.table_name
order by coalesce(b.table_name,c.table_name)