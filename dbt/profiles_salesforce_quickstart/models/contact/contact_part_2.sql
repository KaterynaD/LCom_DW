-- depends_on: {{ source("fivetran_salesforce_quickstart","contact") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","contact"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["matching_email_c", "owner_match_c", "contact_power_of_1_c", "data_quality_score_c", "mql_year_c", "mql_month_c"] ) }}

{% endif %}
