-- depends_on: {{ source("fivetran_salesforce_quickstart","opportunity") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","opportunity"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["meddpicc_identify_the_pain_c", "opp_owner_manager_email_c", "populate_partner_c", "po_number_c", "name", "last_amount_changed_history_id", "key_c", "meddpicc_metrics_c", "record_type_id", "sales_support_email_c", "po_variance_explanation_c", "win_loss_reason_c", "sbqq_primary_quote_c", "shipping_attn_c", "last_modified_by_id", "billing_email_address_c", "state_process_builder_c", "placeholder_c", "owner_id", "description", "shipping_zipcode_c", "partner_c", "vidcode_org_id_c", "x_1_st_contact_email_c", "activity_metric_id", "billing_state_c", "lost_reason_c", "transacted_opp_c", "x_1_st_contact_role_process_builder_c", "x_loss_reason_c", "x_1_st_contact_role_c"] ) }}

{% endif %}
