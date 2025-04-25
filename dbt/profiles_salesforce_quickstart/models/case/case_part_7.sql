-- depends_on: {{ source("fivetran_salesforce_quickstart","case") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","case"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["initial_response_time_c", "time_to_first_reply_hours_c", "round_robin_id_c"] ) }}

{% endif %}
