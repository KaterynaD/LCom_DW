-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_license_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_license_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["lcom_license_start_date_c", "last_activity_date", "lcom_license_end_date_c"] ) }}

{% endif %}
