-- depends_on: {{ source("fivetran_salesforce_quickstart","training_session") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","training_session"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=['closed_date_c','last_activity_date','due_date_c','alternate_start_date_date_only_c','alternate_end_date_c','end_date_c','alternate_start_date_c','start_date_c','system_modstamp','last_referenced_date','created_date','last_viewed_date','last_modified_date','_fivetran_synced'] ) }}

{% endif %}