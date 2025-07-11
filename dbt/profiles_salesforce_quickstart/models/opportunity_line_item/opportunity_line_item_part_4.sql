-- depends_on: {{ source("fivetran_salesforce_quickstart","opportunity_line_item") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","opportunity_line_item"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["easy_code_arr_c", "opportunity_product_line_id_c", "netsuite_sku_c", "opportunity_record_type_c", "pricebook_id_c", "qlbt_c", "product_description_c", "product_revenue_family_c", "price_book_entry_id_c", "assessment_detail_c", "sbqq_parent_id_c", "license_year_ranges_c", "class_c", "last_modified_by_id", "account_c", "sbqq_subscription_type_c", "business_type_opty_product_c", "description", "created_by_id", "record_type_c", "product_2_id", "learning_sbxid_c", "opportunity_id", "name", "vidcode_org_id_c", "training_recipient_email_c", "sbqq_quote_line_c", "id", "netsuite_id_c", "product_code", "migration_tool_c", "codesters_id_c", "pricebook_entry_id"] ) }}

{% endif %}
