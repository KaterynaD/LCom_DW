-- depends_on: {{ source("fivetran_salesforce_quickstart","product_2") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","product_2"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_synced", "created_date", "last_modified_date", "last_viewed_date", "last_referenced_date", "system_modstamp"] ) }}

{% endif %}
