-- depends_on: {{ source("fivetran_salesforce_quickstart","user_role") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","user_role"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_deleted", "may_forecast_manager_share"] ) }}

{% endif %}
