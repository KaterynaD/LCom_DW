-- depends_on: {{ source("fivetran_salesforce_quickstart","nps_survey_responses_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","nps_survey_responses_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["responded_date_c"] ) }}

{% endif %}
