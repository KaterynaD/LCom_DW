-- depends_on: {{ source("fivetran_salesforce_quickstart","contact") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","contact"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_classes_c", "codesters_i_2_c_18_student_completion_c", "school_enrollment_c", "district_enrollment_c", "codesters_i_2_c_student_completion_c", "codesters_students_c", "codesters_i_2_c_18_student_avg_c", "codesters_i_2_c_student_avg_c", "codesters_highest_module_completion_c", "survey_reward_level_c", "age_c", "mailing_latitude", "hubspot_score_c", "dsp_total_launches_c", "planned_classes_c", "force_sync_number_c", "number_of_page_views_c", "extension_c", "other_longitude", "other_latitude", "number_of_platform_visits_c", "eval_total_launches_c", "number_of_sessions_c", "x_2021_md_campaign_c", "mailing_longitude"] ) }}

{% endif %}
