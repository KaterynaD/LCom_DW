-- depends_on: {{ source("fivetran_salesforce_quickstart","order") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","order"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_deleted", "disable_pd_task_script_c", "is_reduction_order", "is_deleted", "sbqq_contracted_c"] ) }}

{% endif %}
