{{
    config(

        materialized='table',        
        sort='start_date', 
        dist='account_id' ,
        post_hook=['{{ update_FACT_TRAINING_SESSION_HISTORY_changed_UK() }}' ]
        
        )
}}

with 
rawdata as (select
{{ safe_select_list_from_profiles(
		table_name='training_session_c',
		alias='sfdc_training_session',
		used_columns=['id','name','account_id_c','owner_id',
 'cancel_reason_c','closed_date_c',
'created_by_id','created_date','curriculum_examples_c',
'end_date_c',
'implementation_google_classroom_c','implementation_notes_c',
'implementation_statement_c','implementation_topics_c','implementation_type_c',
'implementing_grades_c','is_closed_c','last_modified_by_id','last_modified_date',
'notes_c',
'requestor_c','session_attendee_count_c',
'session_grades_attending_c','session_location_address_c',
'session_notes_c','session_participation_method_c','session_subtype_c',
'session_type_c',
'start_date_c','status_c',
'survey_action_items_c','survey_administrator_attendance_c',
'survey_attendee_challenges_c','survey_attendee_count_c',
'survey_notable_discussions_c','survey_notes_c','survey_outcome_as_planned_c',
'survey_outcome_issues_c','survey_recommendations_c',
'survey_teacher_engagement_c','survey_teacher_sentiment_c',
'primary_contact_c','secondary_contact_c'
		],
		profile_src=('profiles','sfdc_schema_audit'),
		base_profile='base',
		current_profile='current'
	) }}
		from {{ source('fivetran_salesforce_quickstart', 'training_session_c') }} as sfdc_training_session
)
,data as (
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
isnull(ts.cancel_reason_c,'{{ var("default_varchar") }}') as cancel_reason,
isnull(cast(ts.closed_date_c as varchar),'{{ var("default_date") }}')::date as closed_date,
isnull(ts.created_by_id,'{{ var("default_varchar") }}') as created_by_id,
isnull(ts.created_date AT TIME ZONE 'PST','{{ var("default_date") }}') as created_date,
isnull(ts.curriculum_examples_c,'{{ var("default_varchar") }}') as curriculum_examples,
isnull(cast(ts.end_date_c as varchar), '{{ var("default_date") }}')::date as end_date,
isnull(ts.implementation_google_classroom_c,'{{ var("default_varchar") }}') as implementation_google_classroom,
isnull(ts.implementation_notes_c,'{{ var("default_varchar") }}') as implementation_notes,
isnull(ts.implementation_statement_c,'{{ var("default_varchar") }}') as implementation_statement,
isnull(ts.implementation_topics_c,'{{ var("default_varchar") }}') as implementation_topics,
isnull(ts.implementation_type_c,'{{ var("default_varchar") }}') as implementation_type,
isnull(ts.implementing_grades_c,'{{ var("default_varchar") }}') as implementing_grades,
isnull(ts.is_closed_c, {{ var("default_boolean") }}) as is_closed,
isnull(ts.last_modified_by_id,'{{ var("default_varchar") }}') as last_modified_by_id,
isnull(ts.last_modified_date AT TIME ZONE 'PST','{{ var("default_date") }}') as last_modified_date,
isnull(ts.notes_c,'{{ var("default_varchar") }}') as notes,
isnull(pc.name,'{{ var("default_varchar") }}') as primary_contact,
isnull(sc.name,'{{ var("default_varchar") }}') as secondary_contact,
isnull(ts.requestor_c,'{{ var("default_ID") }}') as requestor_id,
isnull(ts.session_attendee_count_c, {{ var("default_numeric") }}) as session_attendee_count,
isnull(ts.session_grades_attending_c,'{{ var("default_varchar") }}') as session_grades_attending,
isnull(ts.session_location_address_c,'{{ var("default_varchar") }}') as session_location_address,
isnull(ts.session_notes_c,'{{ var("default_varchar") }}') as session_notes,
isnull(ts.session_participation_method_c,'{{ var("default_varchar") }}') as session_participation_method,
isnull(ts.session_subtype_c,'{{ var("default_varchar") }}') as session_subtype,
isnull(ts.session_type_c,'{{ var("default_varchar") }}') as session_type,
isnull(cast(ts.start_date_c as varchar), '{{ var("default_date") }}')::TIMESTAMP as start_date,
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
isnull(ts.survey_teacher_sentiment_c,'{{ var("default_varchar") }}') as survey_teacher_sentiment
from
  rawdata as ts
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
	,cancel_reason::VARCHAR(765)    
	,closed_date::DATE    
	,created_by_id::VARCHAR(18)    
	,created_date::TIMESTAMP WITHOUT TIME ZONE    
	,curriculum_examples::VARCHAR(4099)     
	,end_date::DATE         
	,implementation_google_classroom::VARCHAR(765)    
	,implementation_notes::VARCHAR(65535)    
	,implementation_statement::VARCHAR(65535)    
	,implementation_topics::VARCHAR(4099)    
	,implementation_type::VARCHAR(765)    
	,implementing_grades::VARCHAR(4099)    
	,is_closed::BOOLEAN    
	,last_modified_by_id::VARCHAR(18)    
	,last_modified_date::TIMESTAMP WITHOUT TIME ZONE        
	,notes::VARCHAR(65535)      	  
	,primary_contact::VARCHAR(363)    
	,secondary_contact::VARCHAR(363)    
	,requestor_id::VARCHAR(300)
	,session_attendee_count::DOUBLE PRECISION    
	,session_grades_attending::VARCHAR(4099)    
	,session_location_address::VARCHAR(65535)    	
	,session_notes::VARCHAR(65535)    
	,session_participation_method::VARCHAR(765)    
	,session_subtype::VARCHAR(765)    
	,session_type::VARCHAR(765)       
	,start_date::TIMESTAMP      
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
  ,'{{ var("loaddate") }}'::TIMESTAMP as loaddate
from data
