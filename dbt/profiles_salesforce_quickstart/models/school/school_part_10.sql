-- depends_on: {{ source("fivetran_salesforce_quickstart","account") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","account"), where_clause="org_type_c='School'", exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["trend_instructional_expenditures_c", "codesters_null_codesters_license_c", "state_profile_c", "district_c", "district_nces_c", "overall_plan_description_c", "facilitator_s_c", "vidcode_org_id_c", "ima_coordinator_c", "billing_state"] ) }}

{% endif %}
