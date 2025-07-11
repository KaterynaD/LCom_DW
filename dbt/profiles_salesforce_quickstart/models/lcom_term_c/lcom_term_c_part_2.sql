-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_term_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_term_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["name", "id", "lcom_django_id_c", "last_modified_by_id", "owner_id", "created_by_id", "lcom_platform_term_id_c"] ) }}

{% endif %}
