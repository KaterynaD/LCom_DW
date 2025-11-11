{{ config(
        materialized='table',        
        sort='learning_object_id', 
        dist='even' 
) }}

with s_info as (SELECT
los.learning_object_id,
BOOL_OR(s.is_cipa_digitalcitizenship) AS meets_digital_citizenship_cipa,
BOOL_OR(s.is_cipa_cyberbullying) AS meets_cyberbullying_cipa,
BOOL_OR(s.is_cipa_digitalcitizenship) AND BOOL_OR(s.is_cipa_cyberbullying) AS meets_both_cipa,
count(distinct s.standard_topic_id) as satisfied_standards
FROM {{ source("dbo","learning_object_standard") }}  los
JOIN {{ source("dbo","standard") }}  s
ON s.standard_topic_id = los.standard_topic_id
GROUP BY los.learning_object_id)
,data as (
select 
isnull(lower(lo.learning_object_id), '{{ var("default_ID") }}') as learning_object_id,
isnull(lo.learning_object_name,'{{ var("default_varchar") }}') learning_object_name,
isnull(it.instruction_type_name,'{{ var("default_varchar") }}') instruction_type,
isnull(ct.topic_name,'{{ var("default_varchar") }}') topic,
isnull(cst.subtopic_name,'{{ var("default_varchar") }}') subtopic,
isnull(si.meets_digital_citizenship_cipa,{{ var("default_boolean") }})   meets_digital_citizenship_cipa,
isnull(si.meets_cyberbullying_cipa,{{ var("default_boolean") }})  meets_cyberbullying_cipa,
isnull(si.meets_both_cipa,{{ var("default_boolean") }}) meets_both_cipa,
isnull(si.satisfied_standards,{{ var("default_numeric") }}) satisfied_standards,
isnull(lo.created_datetime,'{{ var("default_date") }}') created_datetime,
isnull(lo.deleted_datetime,'{{ var("default_date") }}') deleted_datetime
from {{ source("dbo","learning_object") }}  lo
left outer join {{ source("dbo","content_instruction_type") }}  it
on lo.instruction_type_id = it.instruction_type_id
left outer join {{ source("dbo","content_topic") }}  ct
on lo.topic_id = ct.topic_id
left outer join {{ source("dbo","content_subtopic") }} cst
on lo.subtopic_id = cst.subtopic_id
left outer join s_info si
on lo.learning_object_id = si.learning_object_id
union all 
/*default*/
select 
'{{ var("default_ID") }}' learning_object_id,
'{{ var("default_varchar") }}' learning_object_name,
'{{ var("default_varchar") }}' instruction_type,
'{{ var("default_varchar") }}' topic,
'{{ var("default_varchar") }}' subtopic,
{{ var("default_boolean") }}   meets_digital_citizenship_cipa,
{{ var("default_boolean") }}   meets_cyberbullying_cipa,
{{ var("default_boolean") }} meets_both_cipa,
{{ var("default_numeric") }} satisfied_standards,
'{{ var("default_date") }}'created_datetime,
'{{ var("default_date") }}'deleted_datetime
)
select
learning_object_id::varchar(300) as learning_object_id,
learning_object_name::varchar(2000) as learning_object_name,
instruction_type::varchar(100) as instruction_type,     
topic::varchar(100) as topic,
subtopic::varchar(100) as subtopic,
meets_digital_citizenship_cipa::boolean   as meets_digital_citizenship_cipa,
meets_cyberbullying_cipa::boolean  as meets_cyberbullying_cipa,
meets_both_cipa::boolean as meets_both_cipa,        
satisfied_standards::integer as satisfied_standards,
created_datetime::date as created_datetime,
deleted_datetime::date as deleted_datetime,
'{{ var("loaddate") }}'::timestamp as loaddate
from data



