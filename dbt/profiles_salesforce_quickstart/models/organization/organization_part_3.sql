-- depends_on: {{ source("fivetran_salesforce_quickstart","organization") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","organization"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["monthly_page_views_used", "monthly_page_views_entitlement", "num_knowledge_service", "fiscal_year_start_month"] ) }}

{% endif %}
