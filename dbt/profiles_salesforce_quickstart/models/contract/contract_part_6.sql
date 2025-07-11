-- depends_on: {{ source("fivetran_salesforce_quickstart","contract") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","contract"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["source_opp_close_date_c", "sbqq_expiration_date_c", "renewal_opp_close_date_c", "customer_signed_date", "last_activity_date", "start_date", "end_date", "sbqq_amendment_start_date_c", "company_signed_date"] ) }}

{% endif %}
