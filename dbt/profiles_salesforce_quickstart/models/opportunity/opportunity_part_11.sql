-- depends_on: {{ source("fivetran_salesforce_quickstart","opportunity") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","opportunity"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["number_of_products_c", "codesters_number_of_licenses_c", "codesters_number_of_synced_licenses_c", "iq_score", "fiscal_year", "push_count", "fiscal_quarter"] ) }}

{% endif %}
