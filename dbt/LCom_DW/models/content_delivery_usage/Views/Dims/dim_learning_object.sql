{{ config(materialized='view',
   bind=False
)
 }}

select 
lo.learning_object_id,
lo.learning_object_name,
isnull(it.instruction_type_name,'Unknown') instruction_type,
isnull(ct.topic_name,'Unknown') topic,
isnull(cst.subtopic_name,'Unknown') subtopic,
lo.created_datetime,
lo.deleted_datetime
from {{ source("dbo","learning_object") }}  lo
left outer join {{ source("dbo","content_instruction_type") }}  it
on lo.instruction_type_id = it.instruction_type_id
left outer join {{ source("dbo","content_topic") }}  ct
on lo.topic_id = ct.topic_id
left outer join {{ source("dbo","content_subtopic") }} cst
on lo.subtopic_id = cst.subtopic_id
union all 
/*default*/
select 
'00000000-0000-0000-0000-000000000000' learning_object_id,
'Unknown' learning_object_name,
'Unknown' instruction_type,
'Unknown' topic,
'Unknown' subtopic,
null created_datetime,
null deleted_datetime




