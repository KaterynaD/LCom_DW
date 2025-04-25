{{ config(materialized='view',
   bind=False
)
 }}
select 
learning_pathway_id,
learning_pathway_name,
grade_level_code,
created_datetime,
deleted_datetime
from {{ source("dbo","learning_pathway") }}  lp
union all
/*default*/
select 
'00000000-0000-0000-0000-000000000000' learning_pathway_id,
'Unknown' learning_pathway_name,
'UN' grade_level_code,
null created_datetime,
null deleted_datetime



