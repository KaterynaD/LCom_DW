-- depends_on: {{ source("fivetran_salesforce_quickstart","case") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","case"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_account_creation_date_c"] ) }}

{% endif %}
