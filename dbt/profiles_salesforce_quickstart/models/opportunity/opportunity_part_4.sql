-- depends_on: {{ source("fivetran_salesforce_quickstart","opportunity") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","opportunity"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["data_quality_description_c", "arr_bands_c", "netsuite_link_c", "account_link_c", "partner_id_c", "integration_status_c", "purchase_level_c", "opp_record_type_c", "csm_name_c", "district_business_sub_type_c"] ) }}

{% endif %}
