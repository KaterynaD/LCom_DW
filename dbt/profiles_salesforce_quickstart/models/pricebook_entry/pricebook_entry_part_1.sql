-- depends_on: {{ source("fivetran_salesforce_quickstart","pricebook_entry") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","pricebook_entry"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_deleted", "is_archived", "is_deleted", "use_standard_price", "migrated_c", "is_active"] ) }}

{% endif %}
