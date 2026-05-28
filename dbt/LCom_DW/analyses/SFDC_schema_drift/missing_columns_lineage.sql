select
'source.LCom_DW.'+b.schema_name+'.'+b.table_name as source_name,
b.table_name, 
b.column_name,
case when c.pct_nulls is null then 'Missing' else 'Empty' end flg
from (select schema_name, table_name, column_name, pct_nulls from {{ source("profiles","vw_sfdc_schema_audit") }} where profile_name='base')  b
left outer join (select schema_name, table_name, column_name, pct_nulls from {{ source("profiles","vw_sfdc_schema_audit") }} where profile_name='current') c
on b.table_name=c.table_name
and b.column_name=c.column_name
where (c.column_name is null or (c.pct_nulls=100 and b.pct_nulls<100))

    