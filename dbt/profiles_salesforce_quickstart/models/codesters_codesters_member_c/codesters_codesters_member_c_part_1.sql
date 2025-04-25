-- depends_on: {{ source("fivetran_salesforce_quickstart","codesters_codesters_member_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","codesters_codesters_member_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_deleted", "codesters_codesters_profile_demo_c", "codesters_linked_c", "codesters_codesters_profile_account_verified_c", "codesters_codesters_profile_foxycart_c", "codesters_codesters_profile_lti_c", "is_deleted", "codesters_synced_c", "codesters_codesters_profile_google_c"] ) }}

{% endif %}
