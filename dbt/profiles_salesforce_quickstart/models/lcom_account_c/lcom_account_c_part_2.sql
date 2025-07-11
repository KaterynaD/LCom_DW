-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_account_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_account_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["lcom_account_state_c", "lcom_account_id_18_c", "salesforce_account_id_18_c", "name", "lcom_platform_account_id_c", "id", "lcom_django_id_c", "last_modified_by_id", "created_by_id", "salesforce_account_c"] ) }}

{% endif %}
