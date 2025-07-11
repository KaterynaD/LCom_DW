-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_license_site_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_license_site_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["lcom_license_name_created_c"] ) }}

{% endif %}
