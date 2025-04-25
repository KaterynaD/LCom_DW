-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_organization_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_organization_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["salesforce_account_account_id_c", "salesforce_account_ult_parent_acct_id_c", "nces_id_c", "lcom_account_id_c", "x_18_digit_lcom_organization_id_c", "salesforce_account_parent_account_id_c", "state_region_c", "city_c", "country_c", "lcom_account_c", "platform_name_c", "name", "id", "lcom_django_id_c", "last_modified_by_id", "account_c", "platform_url_c", "lcom_organization_type_c", "lcom_organization_parent_c", "lcom_platform_organization_id_c", "created_by_id"] ) }}

{% endif %}
