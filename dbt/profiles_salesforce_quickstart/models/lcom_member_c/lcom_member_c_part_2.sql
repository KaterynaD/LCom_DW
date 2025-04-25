-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_member_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_member_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["lcom_member_unique_identifier_c"] ) }}

{% endif %}
