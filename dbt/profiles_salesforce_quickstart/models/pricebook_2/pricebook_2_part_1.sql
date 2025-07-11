-- depends_on: {{ source("fivetran_salesforce_quickstart","pricebook_2") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","pricebook_2"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_deleted", "is_archived", "is_deleted", "is_standard", "migrated_c", "is_active"] ) }}

{% endif %}
