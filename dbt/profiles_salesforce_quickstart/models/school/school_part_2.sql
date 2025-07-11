-- depends_on: {{ source("fivetran_salesforce_quickstart","account") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","account"), where_clause="org_type_c='School'", exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["actively_prospecting_c", "top_75_account_c", "codesters_account_to_be_migrated_to_prod_c", "agileed_agileed_do_not_update_c", "les_opp_c", "learn_dash_code_sent_c", "state_initiative_c", "expired_renewal_c", "priority_account_c", "closed_district_tx_adoption_c", "reference_customer_c", "x_21_csa_eol_c"] ) }}

{% endif %}
