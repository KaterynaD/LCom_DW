{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select 
event_aggregate_id,
event_version_number,
event_type,
event_data,
isnull(learning_object_id,'00000000-0000-0000-0000-000000000000') learning_object_id,
learning_object_language,
isnull(learning_pathway_id,'00000000-0000-0000-0000-000000000000') learning_pathway_id,
isnull(context_id,'00000000-0000-0000-0000-000000000000') context_id,
isnull(user_primary_teacher_id,'00000000-0000-0000-0000-000000000000') teacher_id,
isnull(user_account_id,'00000000-0000-0000-0000-000000000000') student_id,
case when len(organization_school_id)<36 or organization_school_id is null 
     then '00000000-0000-0000-0000-000000000000' 
     else organization_school_id
end organization_school_id,
isnull(user_grade_level_code,'00') user_grade_level_code,
case when len(organization_district_id)<36 or organization_district_id is null 
     then '00000000-0000-0000-0000-000000000000' 
     else organization_district_id
end organization_district_id,
assignment_launch_id,
raw_score,
score,
possible_score,
percentage_score,
time_spent_seconds,
score_datetime,
effective_score_start_date,
effective_score_end_date,
is_manual,
is_imported,
created_datetime,
modified_datetime,
deleted_datetime
from {{ source("dbo","fact_assignment_completion") }} 
