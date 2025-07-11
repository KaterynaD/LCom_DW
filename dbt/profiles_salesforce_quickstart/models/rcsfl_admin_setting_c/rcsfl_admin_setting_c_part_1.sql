-- depends_on: {{ source("fivetran_salesforce_quickstart","rcsfl_admin_setting_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","rcsfl_admin_setting_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_deleted", "rcsfl_account_related_to_c", "rcsfl_to_voice_mail_c", "is_deleted", "rcsfl_auto_fill_c", "rcsfl_auto_save_c", "rcsfl_auto_select_c", "rcsfl_pop_on_ringing_c", "rcsfl_hvs_mode_c", "rcsfl_save_on_ringing_c", "rcsfl_is_un_mandatory_c"] ) }}

{% endif %}
