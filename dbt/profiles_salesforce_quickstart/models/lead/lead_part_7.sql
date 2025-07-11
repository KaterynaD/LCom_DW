-- depends_on: {{ source("fivetran_salesforce_quickstart","lead") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lead"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["training_date_c", "converted_date", "gong_current_flow_task_due_date_c", "target_start_date_c", "last_activity_date", "last_transfer_date"] ) }}

{% endif %}
