-- depends_on: {{ source("fivetran_salesforce_quickstart","training_session") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","training_session"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=['notes_c','survey_notable_discussions_c','survey_recommendations_c',
'implementation_statement_c','implementation_notes_c',
'session_location_address_c','session_notes_c','survey_notes_c',
'who_chooses_and_assigns_curriculum_c','additional_insight_on_implementation_c',
'are_they_ready_to_implement_c','did_the_training_go_as_planned_c',
'notable_conversations_reactions_c','planning_call_notes_c'
] ) }}

{% endif %}