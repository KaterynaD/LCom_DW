{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}
select 
learning_pathway_id,
CASE
    WHEN learning_pathway_name LIKE 'Digital Readiness Pathway%' THEN 'Digital Readiness'
    WHEN learning_pathway_name = 'Tech Quest' THEN 'Tech Quest'
    ELSE 'Other'
  END AS learning_pathway_group,
  CASE
    WHEN learning_pathway_name LIKE 'Digital Readiness Pathway - Level %' THEN
      'Level ' + SPLIT_PART(learning_pathway_name, ' - Level ', 2)
    ELSE 'Other'
  END AS learning_pathway_subgroup  ,
learning_pathway_name,
grade_level_code,
created_datetime,
deleted_datetime
from {{ source("dbo","learning_pathway") }}  lp
union all
/*default*/
select 
'00000000-0000-0000-0000-000000000000' learning_pathway_id,
'Unknown' learning_pathway_group,
'Unknown' learning_pathway_subgroup,
'Unknown' learning_pathway_name,
'UN' grade_level_code,
null created_datetime,
null deleted_datetime



