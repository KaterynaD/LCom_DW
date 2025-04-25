-- depends_on: {{ source("fivetran_salesforce_quickstart","state_profile_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","state_profile_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["nexus_established_c", "transaction_nexus_established_c", "_fivetran_deleted", "state_nexus_established_c", "does_the_state_have_a_plan_for_k_12_cs_c", "is_deleted", "digital_equity_initiative_c", "registered_with_so_s_c", "state_disability_insurance_tax_required_c", "registered_with_dor_c", "dedicated_state_funding_cs_pd_c"] ) }}

{% endif %}
