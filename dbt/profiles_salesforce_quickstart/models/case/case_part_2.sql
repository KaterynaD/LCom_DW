-- depends_on: {{ source("fivetran_salesforce_quickstart","case") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","case"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["data_quality_score_c", "case_open_month_c", "case_open_year_c", "case_closed_month_c", "case_closed_year_c"] ) }}

{% endif %}
