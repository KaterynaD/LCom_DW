-- depends_on: {{ source("fivetran_salesforce_quickstart","training_session") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","training_session"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=['is_deleted','is_closed_c','session_location_unknown_c','new_district_c','_fivetran_deleted','planning_call_completed_c'] ) }}

{% endif %}