-- depends_on: {{ source("fivetran_salesforce_quickstart","agileed_fieldmapping_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","agileed_fieldmapping_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_synced", "system_modstamp", "last_modified_date", "created_date"] ) }}

{% endif %}
