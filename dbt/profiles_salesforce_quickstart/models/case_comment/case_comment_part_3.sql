-- depends_on: {{ source("fivetran_salesforce_quickstart","case_comment") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","case_comment"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_synced", "system_modstamp", "created_date", "last_modified_date"] ) }}

{% endif %}
