with missing as (select table_name, column_name
from {{ ref("vw_sfdc_schema_drift") }}
where profile_name='base'
except 
select table_name, column_name
from {{ ref("vw_sfdc_schema_drift") }}
where profile_name='current')
select
'source.LCom_DW.'+a.schema_name+'.'+a.table_name as source_name,
a.table_name, 
a.column_name
from {{ ref("vw_sfdc_schema_drift") }} a
join missing m
on a.table_name=m.table_name
and a.column_name=m.column_name
where profile_name='base'
    