-- depends_on: {{ source("fivetran_salesforce_quickstart","object_from_email_default_fields_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","object_from_email_default_fields_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["default_value_number_c"] ) }}

{% endif %}
