-- depends_on: {{ source("fivetran_salesforce_quickstart","business_ops_request_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","business_ops_request_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["close_date_c", "due_date_c", "last_activity_date"] ) }}

{% endif %}
