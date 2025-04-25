-- depends_on: {{ source("fivetran_salesforce_quickstart","lead_status_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lead_status_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["recycle_date_c", "sal_date_c", "mql_date_c", "sql_date_c", "srl_date_c"] ) }}

{% endif %}
