-- depends_on: {{ source("fivetran_salesforce_quickstart","opportunity_line_item") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","opportunity_line_item"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["assessment_c", "is_active_opp_product_c", "_fivetran_deleted", "is_deleted"] ) }}

{% endif %}
