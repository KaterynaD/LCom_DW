-- depends_on: {{ source("fivetran_salesforce_quickstart","campaign") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","campaign"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["hierarchy_budgeted_cost", "budgeted_cost", "codesters_opportunity_amount_c", "hierarchy_expected_revenue", "actual_cost", "amount_won_opportunities", "expected_revenue", "hierarchy_amount_all_opportunities", "hierarchy_amount_won_opportunities", "hierarchy_actual_cost", "amount_all_opportunities"] ) }}

{% endif %}
