-- depends_on: {{ source("fivetran_salesforce_quickstart","case") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","case"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["net_suite_link_c", "thread_id_c", "account_owner_c", "data_quality_description_c"] ) }}

{% endif %}
