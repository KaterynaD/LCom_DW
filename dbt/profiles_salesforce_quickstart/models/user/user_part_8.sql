-- depends_on: {{ source("fivetran_salesforce_quickstart","user") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","user"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["su_access_expiration_date", "out_of_office_end_date_c", "out_of_office_start_date_c"] ) }}

{% endif %}
