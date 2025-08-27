{{
    config(

        materialized='table',        
        sort='start_date', 
        dist='account_id' ,
        post_hook=['{{ update_FACT_TRAINING_SESSION_HISTORY_changed_UK() }}' ]
        
        )
}}

with data as (
select 
isnull(ts.id,'{{ var("default_varchar") }}') as training_session_id,
isnull(ts.name,'{{ var("default_varchar") }}') as name,
isnull(a.account_id, '{{ var("default_ID") }}') as account_id,
isnull(ts.account_id_c, '{{ var("default_ID") }}') as sfdc_account_id,
isnull(e.employee_id, '{{ var("default_ID") }}') as owner_id,
  CASE
    WHEN ts.owner_id = '00GUZ00000KkN1J2AV' THEN 'Professional Development Services'
    WHEN ts.owner_id = '00GUZ00000KaM892AF' THEN 'Service And Training'
    WHEN e.employee_id IS NOT NULL THEN 'Assigned to an owner'
    ELSE COALESCE(ts.owner_id, '')
  END as PDS_group,
isnull(cast(alternate_end_date_c as varchar),'{{ var("default_date") }}')::date as alternate_end_date,
isnull(alternate_end_time_unrestricted_c,'{{ var("default_varchar") }}') as alternate_end_time_unrestricted,
isnull(cast(alternate_start_date_c as varchar),'{{ var("default_date") }}')::date as alternate_start_date,
isnull(alternate_start_time_unrestricted_c,'{{ var("default_varchar") }}') as alternate_start_time_unrestricted,
isnull(ts.cancel_reason_c,'{{ var("default_varchar") }}') as cancel_reason,
isnull(cast(ts.closed_date_c as varchar),'{{ var("default_date") }}')::date as closed_date,
isnull(ts.created_by_id,'{{ var("default_varchar") }}') as created_by_id,
isnull(ts.created_date AT TIME ZONE 'PST','{{ var("default_date") }}') as created_date,
isnull(ts.curriculum_examples_c,'{{ var("default_varchar") }}') as curriculum_examples,
isnull(ts.district_library_c,'{{ var("default_varchar") }}') as district_library,
isnull(cast(ts.end_date_c as varchar), '{{ var("default_date") }}')::date as end_date,
isnull(ts.experience_level_c,'{{ var("default_varchar") }}') as experience_level,
isnull(ts.impelmentation_i_pad_usage_c,'{{ var("default_varchar") }}') as impelmentation_i_pad_usage,
isnull(ts.implementation_advanced_topics_c,'{{ var("default_varchar") }}') as implementation_advanced_topics,
isnull(ts.implementation_elementary_c,'{{ var("default_varchar") }}') as implementation_elementary,
isnull(ts.implementation_frequency_c,'{{ var("default_varchar") }}') as implementation_frequency,
isnull(ts.implementation_goals_c,'{{ var("default_varchar") }}') as implementation_goals,
isnull(ts.implementation_google_classroom_c,'{{ var("default_varchar") }}') as implementation_google_classroom,
isnull(ts.implementation_notes_c,'{{ var("default_varchar") }}') as implementation_notes,
isnull(ts.implementation_statement_c,'{{ var("default_varchar") }}') as implementation_statement,
isnull(ts.implementation_topics_c,'{{ var("default_varchar") }}') as implementation_topics,
isnull(ts.implementation_type_c,'{{ var("default_varchar") }}') as implementation_type,
isnull(ts.implementing_grades_c,'{{ var("default_varchar") }}') as implementing_grades,
isnull(ts.is_closed_c, {{ var("default_boolean") }}) as is_closed,
isnull(ts.last_modified_by_id,'{{ var("default_varchar") }}') as last_modified_by_id,
isnull(ts.last_modified_date AT TIME ZONE 'PST','{{ var("default_date") }}') as last_modified_date,
isnull(ts.learning_path_c,'{{ var("default_varchar") }}') as learning_path,
isnull(ts.new_district_c, {{ var("default_boolean") }}) as new_district,
isnull(ts.notes_c,'{{ var("default_varchar") }}') as notes,
isnull(ts.origin_c,'{{ var("default_varchar") }}') as origin,
isnull(ts.participant_roles_c,'{{ var("default_varchar") }}') as participant_roles,
isnull(ts.person_facilitating_group_tbd_learning_p_c,'{{ var("default_varchar") }}') as person_facilitating_group_tbd_learning_p,
isnull(ts.po_number_c,'{{ var("default_varchar") }}') as po_number,
isnull(ts.presentation_quote_c,'{{ var("default_varchar") }}') as presentation_quote,
isnull(pc.name,'{{ var("default_varchar") }}') as primary_contact,
isnull(sc.name,'{{ var("default_varchar") }}') as secondary_contact,
isnull(ts.session_attendee_count_c, {{ var("default_numeric") }}) as session_attendee_count,
isnull(ts.session_grades_attending_c,'{{ var("default_varchar") }}') as session_grades_attending,
isnull(ts.session_location_address_c,'{{ var("default_varchar") }}') as session_location_address,
isnull(ts.session_location_name_c,'{{ var("default_varchar") }}') as session_location_name,
isnull(ts.session_location_room_c,'{{ var("default_varchar") }}') as session_location_room,
isnull(ts.session_location_unknown_c, {{ var("default_boolean") }}) as session_location_unknown,
isnull(ts.session_notes_c,'{{ var("default_varchar") }}') as session_notes,
isnull(ts.session_participation_method_c,'{{ var("default_varchar") }}') as session_participation_method,
isnull(ts.session_subtype_c,'{{ var("default_varchar") }}') as session_subtype,
isnull(ts.session_type_c,'{{ var("default_varchar") }}') as session_type,
isnull(ts.sessions_per_week_c, {{ var("default_numeric") }}) as sessions_per_week,
isnull(ts.setting_for_student_use_of_curriculum_c,'{{ var("default_varchar") }}') as setting_for_student_use_of_curriculum,
isnull(cast(ts.start_date_c as varchar), '{{ var("default_date") }}')::date as start_date,
isnull(ts.state_program_eligible_confirmation_c,'{{ var("default_varchar") }}') as state_program_eligible_confirmation,
isnull(ts.status_c,'{{ var("default_varchar") }}') as status,
isnull(ts.survey_action_items_c,'{{ var("default_varchar") }}') as survey_action_items,
isnull(ts.survey_administrator_attendance_c,'{{ var("default_varchar") }}') as survey_administrator_attendance,
isnull(ts.survey_attendee_challenges_c,'{{ var("default_varchar") }}') as survey_attendee_challenges,
isnull(ts.survey_attendee_count_c, {{ var("default_numeric") }}) as survey_attendee_count,
isnull(ts.survey_notable_discussions_c,'{{ var("default_varchar") }}') as survey_notable_discussions,
isnull(ts.survey_notes_c,'{{ var("default_varchar") }}') as survey_notes,
isnull(ts.survey_outcome_as_planned_c,'{{ var("default_varchar") }}') as survey_outcome_as_planned,
isnull(ts.survey_outcome_issues_c,'{{ var("default_varchar") }}') as survey_outcome_issues,
isnull(ts.survey_recommendations_c,'{{ var("default_varchar") }}') as survey_recommendations,
isnull(ts.survey_teacher_engagement_c,'{{ var("default_varchar") }}') as survey_teacher_engagement,
isnull(ts.survey_teacher_sentiment_c,'{{ var("default_varchar") }}') as survey_teacher_sentiment,
isnull(ts.where_will_learning_path_be_implemented_c,'{{ var("default_varchar") }}') as where_will_learning_path_be_implemented,
isnull(ts.who_chooses_and_assigns_curriculum_c,'{{ var("default_varchar") }}') as who_chooses_and_assigns_curriculum,
isnull(ts.who_will_be_implementing_c,'{{ var("default_varchar") }}') as who_will_be_implementing	
from
  {{ source('fivetran_salesforce_quickstart', 'training_session_c') }} as ts
  left outer join {{ ref('dim_account') }} as a on ts.account_id_c = a.SFDC_account_id
  left outer join {{ ref('dim_employee') }} as e on ts.owner_id = e.employee_id
  left outer join {{ source('fivetran_salesforce_quickstart','contact') }} as pc on ts.primary_contact_c = pc.id
  left outer join {{ source('fivetran_salesforce_quickstart','contact') }} as sc on ts.secondary_contact_c = sc.id
)
select
  training_session_id::VARCHAR(300)    
	,name::VARCHAR(240)    
	,account_id::VARCHAR(300)    
	,sfdc_account_id::VARCHAR(300)    
	,owner_id::VARCHAR(300)    
	,pds_group::VARCHAR(33)    
	,alternate_end_date::DATE    
	,alternate_end_time_unrestricted::VARCHAR(765)    
	,alternate_start_date::DATE    
	,alternate_start_time_unrestricted::VARCHAR(765)    
	,cancel_reason::VARCHAR(765)    
	,closed_date::DATE    
	,created_by_id::VARCHAR(18)    
	,created_date::TIMESTAMP WITHOUT TIME ZONE    
	,curriculum_examples::VARCHAR(4099)    
	,district_library::VARCHAR(765)    
	,end_date::DATE    
	,experience_level::VARCHAR(4099)    
	,impelmentation_i_pad_usage::VARCHAR(4099)    
	,implementation_advanced_topics::VARCHAR(4099)    
	,implementation_elementary::VARCHAR(4099)    
	,implementation_frequency::VARCHAR(765)    
	,implementation_goals::VARCHAR(4099)    
	,implementation_google_classroom::VARCHAR(765)    
	,implementation_notes::VARCHAR(65535)    
	,implementation_statement::VARCHAR(65535)    
	,implementation_topics::VARCHAR(4099)    
	,implementation_type::VARCHAR(765)    
	,implementing_grades::VARCHAR(4099)    
	,is_closed::BOOLEAN    
	,last_modified_by_id::VARCHAR(18)    
	,last_modified_date::TIMESTAMP WITHOUT TIME ZONE    
	,learning_path::VARCHAR(765)    
	,new_district::BOOLEAN    
	,notes::VARCHAR(65535)    
	,origin::VARCHAR(765)    
	,participant_roles::VARCHAR(4099)    
	,person_facilitating_group_tbd_learning_p::VARCHAR(75)    
	,po_number::VARCHAR(765)    
	,presentation_quote::VARCHAR(765)    
	,primary_contact::VARCHAR(363)    
	,secondary_contact::VARCHAR(363)    
	,session_attendee_count::DOUBLE PRECISION    
	,session_grades_attending::VARCHAR(4099)    
	,session_location_address::VARCHAR(65535)    
	,session_location_name::VARCHAR(240)    
	,session_location_room::VARCHAR(120)    
	,session_location_unknown::BOOLEAN    
	,session_notes::VARCHAR(65535)    
	,session_participation_method::VARCHAR(765)    
	,session_subtype::VARCHAR(765)    
	,session_type::VARCHAR(765)    
	,sessions_per_week::DOUBLE PRECISION    
	,setting_for_student_use_of_curriculum::VARCHAR(4099)    
	,start_date::DATE    
	,state_program_eligible_confirmation::VARCHAR(765)    
	,status::VARCHAR(765)    
	,survey_action_items::VARCHAR(765)    
	,survey_administrator_attendance::VARCHAR(765)    
	,survey_attendee_challenges::VARCHAR(765)    
	,survey_attendee_count::DOUBLE PRECISION    
	,survey_notable_discussions::VARCHAR(65535)    
	,survey_notes::VARCHAR(65535)    
	,survey_outcome_as_planned::VARCHAR(765)    
	,survey_outcome_issues::VARCHAR(4099)    
	,survey_recommendations::VARCHAR(65535)    
	,survey_teacher_engagement::VARCHAR(765)    
	,survey_teacher_sentiment::VARCHAR(765)         
	,where_will_learning_path_be_implemented::VARCHAR(765)    
	,who_chooses_and_assigns_curriculum::VARCHAR(65535)     
	,who_will_be_implementing::VARCHAR(765)
  ,'{{ var("loaddate") }}'::TIMESTAMP as loaddate
from data
