-- depends_on: {{ source("fivetran_salesforce_quickstart","contract") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","contract"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["active_contract_c", "disable_auto_renewal_c", "_fivetran_deleted", "sbqq_renewal_quoted_c", "sbqq_renewal_forecast_c", "update_c", "sbqq_subscription_quantities_combined_c", "sbqq_disable_amendment_co_term_c", "sbqq_preserve_bundle_structure_upon_renewals_c", "sbqq_master_contract_c", "sbqq_evergreen_c", "is_deleted", "sbqq_default_renewal_partners_c", "sbqq_default_renewal_contact_roles_c"] ) }}

{% endif %}
