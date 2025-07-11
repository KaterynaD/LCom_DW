-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_member_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_member_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["lcom_platform_organization_id_c", "lcom_platform_member_id_c", "salesforce_contact_c", "platform_username_c", "lcom_member_roles_c", "name", "id", "lcom_django_id_c", "last_modified_by_id", "lcom_member_email_c", "created_by_id", "lcom_organization_c"] ) }}

{% endif %}
