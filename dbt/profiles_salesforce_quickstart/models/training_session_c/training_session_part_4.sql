-- depends_on: {{ source("fivetran_salesforce_quickstart","training_session") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","training_session"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=['id','owner_id','last_modified_by_id','record_type_id','account_id_c',
'secondary_contact_c','created_by_id','primary_contact_c',
'person_facilitating_group_tbd_learning_p_c','session_location_room_c',
'session_location_name_c','name','training_time_del_c','survey_action_items_c',
'implementation_type_c','where_will_learning_path_be_implemented_c',
'who_chooses_assigns_curriculum_c','implementation_frequency_c',
'alternate_end_time_unrestricted_c','survey_teacher_engagement_c',
'alternate_start_time_unrestricted_c','survey_outcome_as_planned_c','origin_c',
'session_subtype_c','state_program_eligible_confirmation_c',
'who_will_be_implementing_c','learning_path_c','po_number_c',
'survey_teacher_sentiment_c','district_library_c','survey_attendee_challenges_c',
'session_type_c','implementation_google_classroom_c','cancel_reason_c',
'status_c','survey_administrator_attendance_c','presentation_quote_c',
'session_participation_method_c','assignee_c','pds_c','training_session_name_c',
'training_survey_results_c','sync_method_c','account_name_c',
'tiered_service_level_c','participant_roles_c','impelmentation_i_pad_usage_c',
'implementation_goals_c','implementation_advanced_topics_c',
'implementation_topics_c','implementing_grades_c','curriculum_examples_c',
'survey_outcome_issues_c','setting_for_student_use_of_curriculum_c',
'experience_level_c','session_grades_attending_c','implementation_elementary_c'] ) }}

{% endif %}