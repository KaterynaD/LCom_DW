-- depends_on: {{ source("fivetran_salesforce_quickstart","user") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","user"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_synced", "last_modified_date", "last_viewed_date", "created_date", "last_login_date", "offline_trial_expiration_date", "offline_pda_trial_expiration_date", "last_referenced_date", "password_expiration_date", "system_modstamp"] ) }}

{% endif %}
