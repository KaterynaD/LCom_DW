-- depends_on: {{ source("fivetran_salesforce_quickstart","order_item") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","order_item"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_deleted", "sbqq_activated_c", "is_deleted", "sbqq_contracted_c"] ) }}

{% endif %}
