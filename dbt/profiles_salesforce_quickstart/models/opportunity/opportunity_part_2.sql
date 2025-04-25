-- depends_on: {{ source("fivetran_salesforce_quickstart","opportunity") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","opportunity"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["send_odc_c", "stakeholders_confirmed_c", "has_coding_discount_c", "process_builder_opp_c", "codesters_order_to_be_extended_c", "codesters_order_to_be_unenforced_c", "pd_scheduled_c", "pd_services_c", "multi_year_discussed_c", "po_received_c", "sbqq_ordered_c", "disable_odc_c", "is_pd_resources_offered_c", "training_session_created_c", "new_progressive_agreement_c", "spring_promo_c", "data_deletion_archiving_discussed_c", "po_hold_c", "success_plan_shared_c", "rep_says_go_c", "is_closed", "sbqq_renewal_c", "les_opp_c", "other_c", "already_closed_lost_c", "sbqq_contracted_c", "disable_auto_renewal_opp_c", "fire_flow_c", "references_provided_c", "reseller_class_for_les_c", "sbqq_create_contracted_prices_c", "progressive_billing_c", "odc_sent_c", "codesters_diff_migration_c", "international_reseller_c", "assessments_c"] ) }}

{% endif %}
