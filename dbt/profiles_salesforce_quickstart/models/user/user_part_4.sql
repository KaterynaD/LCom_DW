-- depends_on: {{ source("fivetran_salesforce_quickstart","user") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","user"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["number_in_the_queue_c"] ) }}

{% endif %}
