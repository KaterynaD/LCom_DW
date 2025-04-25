-- depends_on: {{ source("fivetran_salesforce_quickstart","user") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","user"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["user_preferences_show_profile_pic_to_guest_users", "user_preferences_hide_chatter_onboarding_splash", "user_preferences_create_lexapps_wtshown", "sbqq_diagnostic_tool_enabled_c", "user_preferences_disable_profile_post_email", "user_preferences_reminder_sound_off", "user_preferences_dis_prof_post_comment_email", "user_preferences_show_email_to_guest_users", "user_preferences_preview_custom_theme", "user_preferences_assistive_actions_enabled_in_action_launcher", "email_preferences_stay_in_touch_reminder", "user_preferences_content_no_email"] ) }}

{% endif %}
