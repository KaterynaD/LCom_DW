-- depends_on: {{ source("fivetran_salesforce_quickstart","training_session") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","training_session"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=['session_attendee_count_c','survey_attendee_count_c','sessions_per_week_c','training_credits_c','total_credits_purchased_c'] ) }}

{% endif %}