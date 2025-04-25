-- depends_on: {{ source("fivetran_salesforce_quickstart","campaign") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","campaign"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["number_of_contacts", "hierarchy_number_of_leads", "number_of_won_opportunities", "number_of_converted_leads", "hierarchy_number_of_converted_leads", "number_of_opportunities", "number_of_leads", "hierarchy_number_of_opportunities", "hierarchy_number_of_contacts", "hierarchy_number_of_won_opportunities", "hierarchy_number_of_responses", "number_of_responses"] ) }}

{% endif %}
