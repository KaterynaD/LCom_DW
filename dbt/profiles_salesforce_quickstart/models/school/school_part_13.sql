-- depends_on: {{ source("fivetran_salesforce_quickstart","account") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","account"), where_clause="org_type_c='School'", exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["number_of_open_opportunities_c", "lcom_organization_count_c", "nps_count_c", "number_of_2020_opps_c", "dq_opportunities_c", "number_of_open_opps_c", "open_renewal_opportunities_c", "of_opps_at_renewal_identified_c", "number_of_renewal_opps_c", "num_opps_c", "lcom_account_count_c", "number_of_won_renewal_opportunities_c", "number_of_employees"] ) }}

{% endif %}
