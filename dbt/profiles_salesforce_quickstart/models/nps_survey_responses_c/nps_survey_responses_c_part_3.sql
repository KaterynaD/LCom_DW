-- depends_on: {{ source("fivetran_salesforce_quickstart","nps_survey_responses_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","nps_survey_responses_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["name_c", "comment_c", "name", "id", "last_modified_by_id", "account_c", "nps_number_c", "gsid_c", "created_by_id", "email_address_c"] ) }}

{% endif %}
