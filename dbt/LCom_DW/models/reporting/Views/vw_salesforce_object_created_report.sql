{{ config(materialized='view', bind=False) }}

with
/*==============================================================================================*/
/*====================================  SFDC     ===============================================*/
/*==============================================================================================*/
data_abn_experiment as (
    select
        'fivetran_salesforce' as schema_name,
        'abn_experiment' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.abn_experiment
)
,
data_abn_experiment_cohort as (
    select
        'fivetran_salesforce' as schema_name,
        'abn_experiment_cohort' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.abn_experiment_cohort
)
,
data_abn_experiment_cohort_attr_val as (
    select
        'fivetran_salesforce' as schema_name,
        'abn_experiment_cohort_attr_val' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.abn_experiment_cohort_attr_val
)
,
data_abn_experiment_engmt_sgnl_mtrc as (
    select
        'fivetran_salesforce' as schema_name,
        'abn_experiment_engmt_sgnl_mtrc' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.abn_experiment_engmt_sgnl_mtrc
)
,
data_account as (
    select
        'fivetran_salesforce' as schema_name,
        'account' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.account
)
,
data_account_brand as (
    select
        'fivetran_salesforce' as schema_name,
        'account_brand' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.account_brand
)
,
data_account_relation_c as (
    select
        'fivetran_salesforce' as schema_name,
        'account_relation_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.account_relation_c
)
,
data_account_relation_history as (
    select
        'fivetran_salesforce' as schema_name,
        'account_relation_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.account_relation_history
)
,
data_activation_target as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_target' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_target
)
,
data_activation_target_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_target_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_target_feed
)
,
data_activation_target_history as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_target_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_target_history
)
,
data_activation_target_platform as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_target_platform' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_target_platform
)
,
data_activation_target_platform_history as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_target_platform_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_target_platform_history
)
,
data_activation_target_secure_ftp as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_target_secure_ftp' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_target_secure_ftp
)
,
data_activation_trgt_int_org_access as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_trgt_int_org_access' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_trgt_int_org_access
)
,
data_activation_trgt_int_org_access_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_trgt_int_org_access_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_trgt_int_org_access_feed
)
,
data_activation_trgt_int_org_access_history as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_trgt_int_org_access_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_trgt_int_org_access_history
)
,
data_activity_roll_up_c as (
    select
        'fivetran_salesforce' as schema_name,
        'activity_roll_up_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activity_roll_up_c
)
,
data_activity_roll_up_history as (
    select
        'fivetran_salesforce' as schema_name,
        'activity_roll_up_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activity_roll_up_history
)
,
data_actv_tgt_platform_field_value as (
    select
        'fivetran_salesforce' as schema_name,
        'actv_tgt_platform_field_value' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.actv_tgt_platform_field_value
)
,
data_actv_tgt_platform_field_value_history as (
    select
        'fivetran_salesforce' as schema_name,
        'actv_tgt_platform_field_value_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.actv_tgt_platform_field_value_history
)
,
data_agileed_connect_link_data_problem_report_c as (
    select
        'fivetran_salesforce' as schema_name,
        'agileed_connect_link_data_problem_report_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.agileed_connect_link_data_problem_report_c
)
,
data_agileed_fieldmapping_c as (
    select
        'fivetran_salesforce' as schema_name,
        'agileed_fieldmapping_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.agileed_fieldmapping_c
)
,
data_ai_job_run as (
    select
        'fivetran_salesforce' as schema_name,
        'ai_job_run' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.ai_job_run
)
,
data_alternative_payment_method as (
    select
        'fivetran_salesforce' as schema_name,
        'alternative_payment_method' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.alternative_payment_method
)
,
data_analytics_user_attr_func_tkn as (
    select
        'fivetran_salesforce' as schema_name,
        'analytics_user_attr_func_tkn' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.analytics_user_attr_func_tkn
)
,
data_apex_code_coverage_aggregate as (
    select
        'fivetran_salesforce' as schema_name,
        'apex_code_coverage_aggregate' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.apex_code_coverage_aggregate
)
,
data_app_usage_assignment as (
    select
        'fivetran_salesforce' as schema_name,
        'app_usage_assignment' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.app_usage_assignment
)
,
data_async_operation_tracker as (
    select
        'fivetran_salesforce' as schema_name,
        'async_operation_tracker' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.async_operation_tracker
)
,
data_attribute_definition as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_definition' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_definition
)
,
data_attribute_definition_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_definition_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_definition_feed
)
,
data_attribute_definition_history as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_definition_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_definition_history
)
,
data_attribute_picklist as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_picklist' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_picklist
)
,
data_attribute_picklist_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_picklist_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_picklist_feed
)
,
data_attribute_picklist_history as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_picklist_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_picklist_history
)
,
data_attribute_picklist_value as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_picklist_value' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_picklist_value
)
,
data_attribute_picklist_value_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_picklist_value_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_picklist_value_feed
)
,
data_attribute_picklist_value_history as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_picklist_value_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_picklist_value_history
)
,
data_automation_analytic_c as (
    select
        'fivetran_salesforce' as schema_name,
        'automation_analytic_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.automation_analytic_c
)
,
data_business_operations_request_c as (
    select
        'fivetran_salesforce' as schema_name,
        'business_operations_request_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.business_operations_request_c
)
,
data_business_operations_request_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'business_operations_request_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.business_operations_request_feed
)
,
data_business_operations_request_history as (
    select
        'fivetran_salesforce' as schema_name,
        'business_operations_request_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.business_operations_request_history
)
,
data_business_ops_request_c as (
    select
        'fivetran_salesforce' as schema_name,
        'business_ops_request_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.business_ops_request_c
)
,
data_calc_affinity_engmt_sgnl as (
    select
        'fivetran_salesforce' as schema_name,
        'calc_affinity_engmt_sgnl' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.calc_affinity_engmt_sgnl
)
,
data_calculated_affinity as (
    select
        'fivetran_salesforce' as schema_name,
        'calculated_affinity' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.calculated_affinity
)
,
data_calculated_affinity_field as (
    select
        'fivetran_salesforce' as schema_name,
        'calculated_affinity_field' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.calculated_affinity_field
)
,
data_calculated_insight_range_bound as (
    select
        'fivetran_salesforce' as schema_name,
        'calculated_insight_range_bound' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.calculated_insight_range_bound
)
,
data_campaign as (
    select
        'fivetran_salesforce' as schema_name,
        'campaign' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.campaign
)
,
data_card_payment_method as (
    select
        'fivetran_salesforce' as schema_name,
        'card_payment_method' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.card_payment_method
)
,
data_case as (
    select
        'fivetran_salesforce' as schema_name,
        'case' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.case
)
,
data_case_comment as (
    select
        'fivetran_salesforce' as schema_name,
        'case_comment' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.case_comment
)
,
data_case_rel_harmonized_content as (
    select
        'fivetran_salesforce' as schema_name,
        'case_rel_harmonized_content' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.case_rel_harmonized_content
)
,
data_case_related_issue as (
    select
        'fivetran_salesforce' as schema_name,
        'case_related_issue' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.case_related_issue
)
,
data_case_solution as (
    select
        'fivetran_salesforce' as schema_name,
        'case_solution' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.case_solution
)
,
data_chat_report_cr_bot_c as (
    select
        'fivetran_salesforce' as schema_name,
        'chat_report_cr_bot_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.chat_report_cr_bot_c
)
,
data_chat_report_cr_custom_label_c as (
    select
        'fivetran_salesforce' as schema_name,
        'chat_report_cr_custom_label_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.chat_report_cr_custom_label_c
)
,
data_chat_report_cr_flow_data_c as (
    select
        'fivetran_salesforce' as schema_name,
        'chat_report_cr_flow_data_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.chat_report_cr_flow_data_c
)
,
data_chat_report_cr_report_type_c as (
    select
        'fivetran_salesforce' as schema_name,
        'chat_report_cr_report_type_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.chat_report_cr_report_type_c
)
,
data_chat_report_cr_skill_based_routing_rule_c as (
    select
        'fivetran_salesforce' as schema_name,
        'chat_report_cr_skill_based_routing_rule_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.chat_report_cr_skill_based_routing_rule_c
)
,
data_codesters_codesters_license_c as (
    select
        'fivetran_salesforce' as schema_name,
        'codesters_codesters_license_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.codesters_codesters_license_c
)
,
data_codesters_codesters_member_c as (
    select
        'fivetran_salesforce' as schema_name,
        'codesters_codesters_member_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.codesters_codesters_member_c
)
,
data_codesters_codesters_organization_c as (
    select
        'fivetran_salesforce' as schema_name,
        'codesters_codesters_organization_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.codesters_codesters_organization_c
)
,
data_codesters_codesters_settings_c as (
    select
        'fivetran_salesforce' as schema_name,
        'codesters_codesters_settings_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.codesters_codesters_settings_c
)
,
data_codesters_opportunity_license_c as (
    select
        'fivetran_salesforce' as schema_name,
        'codesters_opportunity_license_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.codesters_opportunity_license_c
)
,
data_contact as (
    select
        'fivetran_salesforce' as schema_name,
        'contact' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.contact
)
,
data_contact_center_bulk_op as (
    select
        'fivetran_salesforce' as schema_name,
        'contact_center_bulk_op' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.contact_center_bulk_op
)
,
data_contact_history as (
    select
        'fivetran_salesforce' as schema_name,
        'contact_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.contact_history
)
,
data_contract as (
    select
        'fivetran_salesforce' as schema_name,
        'contract' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.contract
)
,
data_conversation_api_log as (
    select
        'fivetran_salesforce' as schema_name,
        'conversation_api_log' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.conversation_api_log
)
,
data_conversation_api_log_obj_sum as (
    select
        'fivetran_salesforce' as schema_name,
        'conversation_api_log_obj_sum' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.conversation_api_log_obj_sum
)
,
data_credit_memo as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo
)
,
data_credit_memo_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo_feed
)
,
data_credit_memo_history as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo_history
)
,
data_credit_memo_inv_application as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo_inv_application' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo_inv_application
)
,
data_credit_memo_inv_application_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo_inv_application_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo_inv_application_feed
)
,
data_credit_memo_inv_application_history as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo_inv_application_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo_inv_application_history
)
,
data_credit_memo_line as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo_line' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo_line
)
,
data_credit_memo_line_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo_line_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo_line_feed
)
,
data_credit_memo_line_history as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo_line_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo_line_history
)
,
data_dashboard_component_localization as (
    select
        'fivetran_salesforce' as schema_name,
        'dashboard_component_localization' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.dashboard_component_localization
)
,
data_dashboard_localization as (
    select
        'fivetran_salesforce' as schema_name,
        'dashboard_localization' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.dashboard_localization
)
,
data_data_assessment_field_metric as (
    select
        'fivetran_salesforce' as schema_name,
        'data_assessment_field_metric' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_assessment_field_metric
)
,
data_data_assessment_metric as (
    select
        'fivetran_salesforce' as schema_name,
        'data_assessment_metric' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_assessment_metric
)
,
data_data_assessment_value_metric as (
    select
        'fivetran_salesforce' as schema_name,
        'data_assessment_value_metric' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_assessment_value_metric
)
,
data_data_content_lens_source as (
    select
        'fivetran_salesforce' as schema_name,
        'data_content_lens_source' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_content_lens_source
)
,
data_data_content_lens_source_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'data_content_lens_source_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_content_lens_source_feed
)
,
data_data_content_lens_source_history as (
    select
        'fivetran_salesforce' as schema_name,
        'data_content_lens_source_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_content_lens_source_history
)
,
data_data_harmonized_model_obj_ref as (
    select
        'fivetran_salesforce' as schema_name,
        'data_harmonized_model_obj_ref' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_harmonized_model_obj_ref
)
,
data_data_knowledge_space as (
    select
        'fivetran_salesforce' as schema_name,
        'data_knowledge_space' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_knowledge_space
)
,
data_data_knowledge_space_session as (
    select
        'fivetran_salesforce' as schema_name,
        'data_knowledge_space_session' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_knowledge_space_session
)
,
data_data_knowledge_src_file_ref as (
    select
        'fivetran_salesforce' as schema_name,
        'data_knowledge_src_file_ref' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_knowledge_src_file_ref
)
,
data_data_obj_secondary_index as (
    select
        'fivetran_salesforce' as schema_name,
        'data_obj_secondary_index' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_obj_secondary_index
)
,
data_data_obj_secondary_index_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'data_obj_secondary_index_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_obj_secondary_index_feed
)
,
data_data_obj_secondary_index_history as (
    select
        'fivetran_salesforce' as schema_name,
        'data_obj_secondary_index_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_obj_secondary_index_history
)
,
data_data_quick_attribute as (
    select
        'fivetran_salesforce' as schema_name,
        'data_quick_attribute' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_quick_attribute
)
,
data_data_quick_attribute_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'data_quick_attribute_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_quick_attribute_feed
)
,
data_data_quick_attribute_history as (
    select
        'fivetran_salesforce' as schema_name,
        'data_quick_attribute_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_quick_attribute_history
)
,
data_data_space as (
    select
        'fivetran_salesforce' as schema_name,
        'data_space' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_space
)
,
data_data_space_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'data_space_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_space_feed
)
,
data_data_space_history as (
    select
        'fivetran_salesforce' as schema_name,
        'data_space_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_space_history
)
,
data_digital_wallet as (
    select
        'fivetran_salesforce' as schema_name,
        'digital_wallet' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.digital_wallet
)
,
data_doc_generation_query_result as (
    select
        'fivetran_salesforce' as schema_name,
        'doc_generation_query_result' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.doc_generation_query_result
)
,
data_doc_generation_query_result_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'doc_generation_query_result_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.doc_generation_query_result_feed
)
,
data_doc_generation_query_result_history as (
    select
        'fivetran_salesforce' as schema_name,
        'doc_generation_query_result_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.doc_generation_query_result_history
)
,
data_document_generation_process as (
    select
        'fivetran_salesforce' as schema_name,
        'document_generation_process' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.document_generation_process
)
,
data_engagement_signal as (
    select
        'fivetran_salesforce' as schema_name,
        'engagement_signal' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.engagement_signal
)
,
data_engagement_signal_cmpnd_metric as (
    select
        'fivetran_salesforce' as schema_name,
        'engagement_signal_cmpnd_metric' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.engagement_signal_cmpnd_metric
)
,
data_engagement_signal_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'engagement_signal_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.engagement_signal_feed
)
,
data_engagement_signal_history as (
    select
        'fivetran_salesforce' as schema_name,
        'engagement_signal_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.engagement_signal_history
)
,
data_engagement_signal_metric as (
    select
        'fivetran_salesforce' as schema_name,
        'engagement_signal_metric' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.engagement_signal_metric
)
,
data_epic_c as (
    select
        'fivetran_salesforce' as schema_name,
        'epic_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.epic_c
)
,
data_epic_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'epic_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.epic_feed
)
,
data_epic_history as (
    select
        'fivetran_salesforce' as schema_name,
        'epic_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.epic_history
)
,
data_flow_personal_configuration_c as (
    select
        'fivetran_salesforce' as schema_name,
        'flow_personal_configuration_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.flow_personal_configuration_c
)
,
data_flow_table_view_definition_c as (
    select
        'fivetran_salesforce' as schema_name,
        'flow_table_view_definition_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.flow_table_view_definition_c
)
,
data_forecasting_submission as (
    select
        'fivetran_salesforce' as schema_name,
        'forecasting_submission' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.forecasting_submission
)
,
data_forecasting_submission_item as (
    select
        'fivetran_salesforce' as schema_name,
        'forecasting_submission_item' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.forecasting_submission_item
)
,
data_goal_assignment as (
    select
        'fivetran_salesforce' as schema_name,
        'goal_assignment' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.goal_assignment
)
,
data_goal_assignment_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'goal_assignment_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.goal_assignment_feed
)
,
data_goal_assignment_history as (
    select
        'fivetran_salesforce' as schema_name,
        'goal_assignment_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.goal_assignment_history
)
,
data_goal_assignment_recommendation as (
    select
        'fivetran_salesforce' as schema_name,
        'goal_assignment_recommendation' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.goal_assignment_recommendation
)
,
data_goal_definition as (
    select
        'fivetran_salesforce' as schema_name,
        'goal_definition' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.goal_definition
)
,
data_goal_definition_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'goal_definition_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.goal_definition_feed
)
,
data_goal_definition_history as (
    select
        'fivetran_salesforce' as schema_name,
        'goal_definition_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.goal_definition_history
)
,
data_incp_incident_lv_fields_c as (
    select
        'fivetran_salesforce' as schema_name,
        'incp_incident_lv_fields_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.incp_incident_lv_fields_c
)
,
data_incp_time_zone_selection_c as (
    select
        'fivetran_salesforce' as schema_name,
        'incp_time_zone_selection_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.incp_time_zone_selection_c
)
,
data_invoice as (
    select
        'fivetran_salesforce' as schema_name,
        'invoice' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.invoice
)
,
data_invoice_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'invoice_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.invoice_feed
)
,
data_invoice_history as (
    select
        'fivetran_salesforce' as schema_name,
        'invoice_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.invoice_history
)
,
data_invoice_line as (
    select
        'fivetran_salesforce' as schema_name,
        'invoice_line' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.invoice_line
)
,
data_invoice_line_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'invoice_line_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.invoice_line_feed
)
,
data_invoice_line_history as (
    select
        'fivetran_salesforce' as schema_name,
        'invoice_line_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.invoice_line_history
)
,
data_lcom_account_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_account_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_account_c
)
,
data_lcom_account_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_account_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_account_feed
)
,
data_lcom_license_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_license_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_license_c
)
,
data_lcom_license_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_license_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_license_feed
)
,
data_lcom_license_site_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_license_site_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_license_site_c
)
,
data_lcom_license_site_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_license_site_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_license_site_feed
)
,
data_lcom_member_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_member_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_member_c
)
,
data_lcom_member_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_member_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_member_feed
)
,
data_lcom_opportunity_site_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_opportunity_site_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_opportunity_site_c
)
,
data_lcom_opportunity_term_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_opportunity_term_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_opportunity_term_c
)
,
data_lcom_opportunity_term_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_opportunity_term_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_opportunity_term_feed
)
,
data_lcom_opportunity_term_history as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_opportunity_term_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_opportunity_term_history
)
,
data_lcom_order_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_order_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_order_c
)
,
data_lcom_order_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_order_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_order_feed
)
,
data_lcom_order_line_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_order_line_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_order_line_c
)
,
data_lcom_order_line_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_order_line_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_order_line_feed
)
,
data_lcom_order_modification_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_order_modification_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_order_modification_c
)
,
data_lcom_order_modification_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_order_modification_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_order_modification_feed
)
,
data_lcom_organization_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_organization_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_organization_c
)
,
data_lcom_organization_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_organization_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_organization_feed
)
,
data_lcom_suite_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_suite_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_suite_c
)
,
data_lcom_suite_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_suite_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_suite_feed
)
,
data_lcom_term_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_term_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_term_c
)
,
data_lcom_term_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_term_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_term_feed
)
,
data_lead as (
    select
        'fivetran_salesforce' as schema_name,
        'lead' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lead
)
,
data_lead_status_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lead_status_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lead_status_c
)
,
data_learning_com_c as (
    select
        'fivetran_salesforce' as schema_name,
        'learning_com_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.learning_com_c
)
,
data_learning_com_district_license_c as (
    select
        'fivetran_salesforce' as schema_name,
        'learning_com_district_license_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.learning_com_district_license_c
)
,
data_learning_com_district_license_history as (
    select
        'fivetran_salesforce' as schema_name,
        'learning_com_district_license_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.learning_com_district_license_history
)
,
data_learning_com_order_c as (
    select
        'fivetran_salesforce' as schema_name,
        'learning_com_order_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.learning_com_order_c
)
,
data_learning_com_school_license_c as (
    select
        'fivetran_salesforce' as schema_name,
        'learning_com_school_license_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.learning_com_school_license_c
)
,
data_learning_com_school_license_history as (
    select
        'fivetran_salesforce' as schema_name,
        'learning_com_school_license_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.learning_com_school_license_history
)
,
data_market_segment as (
    select
        'fivetran_salesforce' as schema_name,
        'market_segment' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.market_segment
)
,
data_market_segment_activation as (
    select
        'fivetran_salesforce' as schema_name,
        'market_segment_activation' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.market_segment_activation
)
,
data_market_segment_activation_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'market_segment_activation_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.market_segment_activation_feed
)
,
data_market_segment_activation_history as (
    select
        'fivetran_salesforce' as schema_name,
        'market_segment_activation_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.market_segment_activation_history
)
,
data_market_segment_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'market_segment_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.market_segment_feed
)
,
data_market_segment_history as (
    select
        'fivetran_salesforce' as schema_name,
        'market_segment_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.market_segment_history
)
,
data_mkt_sgmnt_actvtn_aud_attribute as (
    select
        'fivetran_salesforce' as schema_name,
        'mkt_sgmnt_actvtn_aud_attribute' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mkt_sgmnt_actvtn_aud_attribute
)
,
data_mkt_sgmnt_actvtn_contact_point as (
    select
        'fivetran_salesforce' as schema_name,
        'mkt_sgmnt_actvtn_contact_point' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mkt_sgmnt_actvtn_contact_point
)
,
data_mkt_sgmt_actv_contact_pt_field as (
    select
        'fivetran_salesforce' as schema_name,
        'mkt_sgmt_actv_contact_pt_field' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mkt_sgmt_actv_contact_pt_field
)
,
data_mkt_sgmt_actv_contact_pt_src as (
    select
        'fivetran_salesforce' as schema_name,
        'mkt_sgmt_actv_contact_pt_src' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mkt_sgmt_actv_contact_pt_src
)
,
data_mkt_sgmt_actv_data_model_fld as (
    select
        'fivetran_salesforce' as schema_name,
        'mkt_sgmt_actv_data_model_fld' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mkt_sgmt_actv_data_model_fld
)
,
data_mkt_sgmt_actv_data_source as (
    select
        'fivetran_salesforce' as schema_name,
        'mkt_sgmt_actv_data_source' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mkt_sgmt_actv_data_source
)
,
data_ml_intent_utterance_suggestion as (
    select
        'fivetran_salesforce' as schema_name,
        'ml_intent_utterance_suggestion' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.ml_intent_utterance_suggestion
)
,
data_mlmodel as (
    select
        'fivetran_salesforce' as schema_name,
        'mlmodel' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mlmodel
)
,
data_mlmodel_factor as (
    select
        'fivetran_salesforce' as schema_name,
        'mlmodel_factor' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mlmodel_factor
)
,
data_mlmodel_factor_component as (
    select
        'fivetran_salesforce' as schema_name,
        'mlmodel_factor_component' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mlmodel_factor_component
)
,
data_mlmodel_metric as (
    select
        'fivetran_salesforce' as schema_name,
        'mlmodel_metric' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mlmodel_metric
)
,
data_nps_survey_responses_c as (
    select
        'fivetran_salesforce' as schema_name,
        'nps_survey_responses_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.nps_survey_responses_c
)
,
data_object_from_email_accepted_fields_c as (
    select
        'fivetran_salesforce' as schema_name,
        'object_from_email_accepted_fields_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.object_from_email_accepted_fields_c
)
,
data_object_from_email_default_fields_c as (
    select
        'fivetran_salesforce' as schema_name,
        'object_from_email_default_fields_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.object_from_email_default_fields_c
)
,
data_object_milestone_pause_time as (
    select
        'fivetran_salesforce' as schema_name,
        'object_milestone_pause_time' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.object_milestone_pause_time
)
,
data_omni_component_error_log as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_component_error_log' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_component_error_log
)
,
data_omni_component_error_log_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_component_error_log_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_component_error_log_feed
)
,
data_omni_data_pack as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_data_pack' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_data_pack
)
,
data_omni_data_pack_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_data_pack_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_data_pack_feed
)
,
data_omni_data_transform as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_data_transform' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_data_transform
)
,
data_omni_data_transform_item as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_data_transform_item' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_data_transform_item
)
,
data_omni_esignature_template as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_esignature_template' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_esignature_template
)
,
data_omni_global_auto_number as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_global_auto_number' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_global_auto_number
)
,
data_omni_global_auto_number_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_global_auto_number_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_global_auto_number_feed
)
,
data_omni_process as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_process' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_process
)
,
data_omni_process_compilation as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_process_compilation' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_process_compilation
)
,
data_omni_process_element as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_process_element' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_process_element
)
,
data_omni_process_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_process_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_process_feed
)
,
data_omni_process_transient_data as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_process_transient_data' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_process_transient_data
)
,
data_omni_process_transient_data_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_process_transient_data_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_process_transient_data_feed
)
,
data_omni_script_saved_session as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_script_saved_session' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_script_saved_session
)
,
data_omni_script_saved_session_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_script_saved_session_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_script_saved_session_feed
)
,
data_omni_ui_card as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_ui_card' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_ui_card
)
,
data_omni_ui_card_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_ui_card_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_ui_card_feed
)
,
data_operating_hours as (
    select
        'fivetran_salesforce' as schema_name,
        'operating_hours' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.operating_hours
)
,
data_operating_hours_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'operating_hours_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.operating_hours_feed
)
,
data_operating_hours_history as (
    select
        'fivetran_salesforce' as schema_name,
        'operating_hours_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.operating_hours_history
)
,
data_operating_hours_holiday as (
    select
        'fivetran_salesforce' as schema_name,
        'operating_hours_holiday' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.operating_hours_holiday
)
,
data_operating_hours_holiday_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'operating_hours_holiday_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.operating_hours_holiday_feed
)
,
data_operating_hours_holiday_history as (
    select
        'fivetran_salesforce' as schema_name,
        'operating_hours_holiday_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.operating_hours_holiday_history
)
,
data_opportunity as (
    select
        'fivetran_salesforce' as schema_name,
        'opportunity' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.opportunity
)
,
data_opportunity_line_item as (
    select
        'fivetran_salesforce' as schema_name,
        'opportunity_line_item' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.opportunity_line_item
)
,
data_order as (
    select
        'fivetran_salesforce' as schema_name,
        'order' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.order
)
,
data_order_detail_confirmation_c as (
    select
        'fivetran_salesforce' as schema_name,
        'order_detail_confirmation_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.order_detail_confirmation_c
)
,
data_order_detail_confirmation_history as (
    select
        'fivetran_salesforce' as schema_name,
        'order_detail_confirmation_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.order_detail_confirmation_history
)
,
data_order_item as (
    select
        'fivetran_salesforce' as schema_name,
        'order_item' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.order_item
)
,
data_organization as (
    select
        'fivetran_salesforce' as schema_name,
        'organization' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.organization
)
,
data_payment as (
    select
        'fivetran_salesforce' as schema_name,
        'payment' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.payment
)
,
data_payment_auth_adjustment as (
    select
        'fivetran_salesforce' as schema_name,
        'payment_auth_adjustment' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.payment_auth_adjustment
)
,
data_payment_authorization as (
    select
        'fivetran_salesforce' as schema_name,
        'payment_authorization' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.payment_authorization
)
,
data_payment_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'payment_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.payment_feed
)
,
data_payment_gateway as (
    select
        'fivetran_salesforce' as schema_name,
        'payment_gateway' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.payment_gateway
)
,
data_payment_gateway_log as (
    select
        'fivetran_salesforce' as schema_name,
        'payment_gateway_log' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.payment_gateway_log
)
,
data_payment_group as (
    select
        'fivetran_salesforce' as schema_name,
        'payment_group' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.payment_group
)
,
data_payment_line_invoice as (
    select
        'fivetran_salesforce' as schema_name,
        'payment_line_invoice' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.payment_line_invoice
)
,
data_personalization_schema as (
    select
        'fivetran_salesforce' as schema_name,
        'personalization_schema' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.personalization_schema
)
,
data_pricebook_2 as (
    select
        'fivetran_salesforce' as schema_name,
        'pricebook_2' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.pricebook_2
)
,
data_pricebook_entry as (
    select
        'fivetran_salesforce' as schema_name,
        'pricebook_entry' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.pricebook_entry
)
,
data_product_2 as (
    select
        'fivetran_salesforce' as schema_name,
        'product_2' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_2
)
,
data_product_catalog as (
    select
        'fivetran_salesforce' as schema_name,
        'product_catalog' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_catalog
)
,
data_product_catalog_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'product_catalog_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_catalog_feed
)
,
data_product_catalog_history as (
    select
        'fivetran_salesforce' as schema_name,
        'product_catalog_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_catalog_history
)
,
data_product_category as (
    select
        'fivetran_salesforce' as schema_name,
        'product_category' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_category
)
,
data_product_category_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'product_category_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_category_feed
)
,
data_product_category_history as (
    select
        'fivetran_salesforce' as schema_name,
        'product_category_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_category_history
)
,
data_product_category_product as (
    select
        'fivetran_salesforce' as schema_name,
        'product_category_product' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_category_product
)
,
data_product_category_product_history as (
    select
        'fivetran_salesforce' as schema_name,
        'product_category_product_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_category_product_history
)
,
data_product_component_group as (
    select
        'fivetran_salesforce' as schema_name,
        'product_component_group' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_component_group
)
,
data_product_component_group_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'product_component_group_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_component_group_feed
)
,
data_product_component_group_history as (
    select
        'fivetran_salesforce' as schema_name,
        'product_component_group_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_component_group_history
)
,
data_product_config_flow_assignment as (
    select
        'fivetran_salesforce' as schema_name,
        'product_config_flow_assignment' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_config_flow_assignment
)
,
data_product_configuration_flow as (
    select
        'fivetran_salesforce' as schema_name,
        'product_configuration_flow' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_configuration_flow
)
,
data_product_configuration_flow_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'product_configuration_flow_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_configuration_flow_feed
)
,
data_product_configuration_flow_history as (
    select
        'fivetran_salesforce' as schema_name,
        'product_configuration_flow_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_configuration_flow_history
)
,
data_product_related_component as (
    select
        'fivetran_salesforce' as schema_name,
        'product_related_component' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_related_component
)
,
data_product_relationship_type as (
    select
        'fivetran_salesforce' as schema_name,
        'product_relationship_type' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_relationship_type
)
,
data_product_selling_model as (
    select
        'fivetran_salesforce' as schema_name,
        'product_selling_model' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_selling_model
)
,
data_product_selling_model_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'product_selling_model_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_selling_model_feed
)
,
data_product_selling_model_history as (
    select
        'fivetran_salesforce' as schema_name,
        'product_selling_model_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_selling_model_history
)
,
data_product_selling_model_option as (
    select
        'fivetran_salesforce' as schema_name,
        'product_selling_model_option' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_selling_model_option
)
,
data_profile as (
    select
        'fivetran_salesforce' as schema_name,
        'profile' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.profile
)
,
data_prompt_action as (
    select
        'fivetran_salesforce' as schema_name,
        'prompt_action' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.prompt_action
)
,
data_prompt_error as (
    select
        'fivetran_salesforce' as schema_name,
        'prompt_error' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.prompt_error
)
,
data_proration_policy as (
    select
        'fivetran_salesforce' as schema_name,
        'proration_policy' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.proration_policy
)
,
data_rcsfl_admin_setting_c as (
    select
        'fivetran_salesforce' as schema_name,
        'rcsfl_admin_setting_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.rcsfl_admin_setting_c
)
,
data_rcsfl_ai_notes_c as (
    select
        'fivetran_salesforce' as schema_name,
        'rcsfl_ai_notes_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.rcsfl_ai_notes_c
)
,
data_rcsfl_ring_central_webinar_token_c as (
    select
        'fivetran_salesforce' as schema_name,
        'rcsfl_ring_central_webinar_token_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.rcsfl_ring_central_webinar_token_c
)
,
data_record_type as (
    select
        'fivetran_salesforce' as schema_name,
        'record_type' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.record_type
)
,
data_refund as (
    select
        'fivetran_salesforce' as schema_name,
        'refund' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.refund
)
,
data_refund_line_payment as (
    select
        'fivetran_salesforce' as schema_name,
        'refund_line_payment' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.refund_line_payment
)
,
data_revenue_async_operation as (
    select
        'fivetran_salesforce' as schema_name,
        'revenue_async_operation' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.revenue_async_operation
)
,
data_revenue_transaction_error_log as (
    select
        'fivetran_salesforce' as schema_name,
        'revenue_transaction_error_log' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.revenue_transaction_error_log
)
,
data_sbqq_field_metadata_c as (
    select
        'fivetran_salesforce' as schema_name,
        'sbqq_field_metadata_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sbqq_field_metadata_c
)
,
data_sbqq_product_option_c as (
    select
        'fivetran_salesforce' as schema_name,
        'sbqq_product_option_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sbqq_product_option_c
)
,
data_sbqq_quote_c as (
    select
        'fivetran_salesforce' as schema_name,
        'sbqq_quote_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sbqq_quote_c
)
,
data_sbqq_quote_line_c as (
    select
        'fivetran_salesforce' as schema_name,
        'sbqq_quote_line_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sbqq_quote_line_c
)
,
data_sbqq_quote_line_group_c as (
    select
        'fivetran_salesforce' as schema_name,
        'sbqq_quote_line_group_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sbqq_quote_line_group_c
)
,
data_sender_email_address as (
    select
        'fivetran_salesforce' as schema_name,
        'sender_email_address' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sender_email_address
)
,
data_service_and_training_request_c as (
    select
        'fivetran_salesforce' as schema_name,
        'service_and_training_request_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.service_and_training_request_c
)
,
data_service_and_training_request_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'service_and_training_request_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.service_and_training_request_feed
)
,
data_service_and_training_request_history as (
    select
        'fivetran_salesforce' as schema_name,
        'service_and_training_request_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.service_and_training_request_history
)
,
data_setup_assistant_step as (
    select
        'fivetran_salesforce' as schema_name,
        'setup_assistant_step' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.setup_assistant_step
)
,
data_sfdc_partner_sbscr_offer as (
    select
        'fivetran_salesforce' as schema_name,
        'sfdc_partner_sbscr_offer' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sfdc_partner_sbscr_offer
)
,
data_sfdc_partner_sbscr_offer_history as (
    select
        'fivetran_salesforce' as schema_name,
        'sfdc_partner_sbscr_offer_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sfdc_partner_sbscr_offer_history
)
,
data_sfdc_partner_sbscr_offer_item as (
    select
        'fivetran_salesforce' as schema_name,
        'sfdc_partner_sbscr_offer_item' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sfdc_partner_sbscr_offer_item
)
,
data_slack_channel_related_record as (
    select
        'fivetran_salesforce' as schema_name,
        'slack_channel_related_record' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.slack_channel_related_record
)
,
data_state_profile_c as (
    select
        'fivetran_salesforce' as schema_name,
        'state_profile_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.state_profile_c
)
,
data_switches_c as (
    select
        'fivetran_salesforce' as schema_name,
        'switches_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.switches_c
)
,
data_team_c as (
    select
        'fivetran_salesforce' as schema_name,
        'team_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.team_c
)
,
data_team_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'team_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.team_feed
)
,
data_team_history as (
    select
        'fivetran_salesforce' as schema_name,
        'team_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.team_history
)
,
data_team_member_c as (
    select
        'fivetran_salesforce' as schema_name,
        'team_member_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.team_member_c
)
,
data_team_member_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'team_member_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.team_member_feed
)
,
data_team_member_history as (
    select
        'fivetran_salesforce' as schema_name,
        'team_member_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.team_member_history
)
,
data_time_slot as (
    select
        'fivetran_salesforce' as schema_name,
        'time_slot' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.time_slot
)
,
data_time_slot_history as (
    select
        'fivetran_salesforce' as schema_name,
        'time_slot_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.time_slot_history
)
,
data_training_session_c as (
    select
        'fivetran_salesforce' as schema_name,
        'training_session_c' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.training_session_c
)
,
data_training_session_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'training_session_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.training_session_feed
)
,
data_unit_of_measure as (
    select
        'fivetran_salesforce' as schema_name,
        'unit_of_measure' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.unit_of_measure
)
,
data_unstructured_storage_space as (
    select
        'fivetran_salesforce' as schema_name,
        'unstructured_storage_space' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.unstructured_storage_space
)
,
data_user as (
    select
        'fivetran_salesforce' as schema_name,
        'user' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.user
)
,
data_user_history as (
    select
        'fivetran_salesforce' as schema_name,
        'user_history' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.user_history
)
,
data_user_prov_account as (
    select
        'fivetran_salesforce' as schema_name,
        'user_prov_account' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.user_prov_account
)
,
data_user_prov_account_staging as (
    select
        'fivetran_salesforce' as schema_name,
        'user_prov_account_staging' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.user_prov_account_staging
)
,
data_user_prov_mock_target as (
    select
        'fivetran_salesforce' as schema_name,
        'user_prov_mock_target' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.user_prov_mock_target
)
,
data_user_provisioning_log as (
    select
        'fivetran_salesforce' as schema_name,
        'user_provisioning_log' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.user_provisioning_log
)
,
data_user_provisioning_request as (
    select
        'fivetran_salesforce' as schema_name,
        'user_provisioning_request' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.user_provisioning_request
)
,
data_video_call as (
    select
        'fivetran_salesforce' as schema_name,
        'video_call' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.video_call
)
,
data_video_call_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'video_call_feed' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.video_call_feed
)
,
data_video_call_participant as (
    select
        'fivetran_salesforce' as schema_name,
        'video_call_participant' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.video_call_participant
)
,
data_video_call_recording as (
    select
        'fivetran_salesforce' as schema_name,
        'video_call_recording' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.video_call_recording
)
,
data_voice_call_recording as (
    select
        'fivetran_salesforce' as schema_name,
        'voice_call_recording' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.voice_call_recording
)
,
data_voice_chnl_interaction_event as (
    select
        'fivetran_salesforce' as schema_name,
        'voice_chnl_interaction_event' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.voice_chnl_interaction_event
)
,
data_voice_chnl_intrctn_dtl_event as (
    select
        'fivetran_salesforce' as schema_name,
        'voice_chnl_intrctn_dtl_event' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.voice_chnl_intrctn_dtl_event
)
,
data_web_link as (
    select
        'fivetran_salesforce' as schema_name,
        'web_link' as table_name,
        count(1) as total_rows,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.web_link
)
/*==============================================================================================*/
/*====================================  SFDC  final queries   ==================================*/
/*==============================================================================================*/
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.abn_experiment f
join data_abn_experiment
    on f.created_date::date = data_abn_experiment.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.abn_experiment_cohort f
join data_abn_experiment_cohort
    on f.created_date::date = data_abn_experiment_cohort.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.abn_experiment_cohort_attr_val f
join data_abn_experiment_cohort_attr_val
    on f.created_date::date = data_abn_experiment_cohort_attr_val.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.abn_experiment_engmt_sgnl_mtrc f
join data_abn_experiment_engmt_sgnl_mtrc
    on f.created_date::date = data_abn_experiment_engmt_sgnl_mtrc.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.account f
join data_account
    on f.created_date::date = data_account.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.account_brand f
join data_account_brand
    on f.created_date::date = data_account_brand.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.account_relation_c f
join data_account_relation_c
    on f.created_date::date = data_account_relation_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.account_relation_history f
join data_account_relation_history
    on f.created_date::date = data_account_relation_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_target f
join data_activation_target
    on f.created_date::date = data_activation_target.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_target_feed f
join data_activation_target_feed
    on f.created_date::date = data_activation_target_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_target_history f
join data_activation_target_history
    on f.created_date::date = data_activation_target_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_target_platform f
join data_activation_target_platform
    on f.created_date::date = data_activation_target_platform.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_target_platform_history f
join data_activation_target_platform_history
    on f.created_date::date = data_activation_target_platform_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_target_secure_ftp f
join data_activation_target_secure_ftp
    on f.created_date::date = data_activation_target_secure_ftp.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_trgt_int_org_access f
join data_activation_trgt_int_org_access
    on f.created_date::date = data_activation_trgt_int_org_access.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_trgt_int_org_access_feed f
join data_activation_trgt_int_org_access_feed
    on f.created_date::date = data_activation_trgt_int_org_access_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_trgt_int_org_access_history f
join data_activation_trgt_int_org_access_history
    on f.created_date::date = data_activation_trgt_int_org_access_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activity_roll_up_c f
join data_activity_roll_up_c
    on f.created_date::date = data_activity_roll_up_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activity_roll_up_history f
join data_activity_roll_up_history
    on f.created_date::date = data_activity_roll_up_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.actv_tgt_platform_field_value f
join data_actv_tgt_platform_field_value
    on f.created_date::date = data_actv_tgt_platform_field_value.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.actv_tgt_platform_field_value_history f
join data_actv_tgt_platform_field_value_history
    on f.created_date::date = data_actv_tgt_platform_field_value_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.agileed_connect_link_data_problem_report_c f
join data_agileed_connect_link_data_problem_report_c
    on f.created_date::date = data_agileed_connect_link_data_problem_report_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.agileed_fieldmapping_c f
join data_agileed_fieldmapping_c
    on f.created_date::date = data_agileed_fieldmapping_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.ai_job_run f
join data_ai_job_run
    on f.created_date::date = data_ai_job_run.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.alternative_payment_method f
join data_alternative_payment_method
    on f.created_date::date = data_alternative_payment_method.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.analytics_user_attr_func_tkn f
join data_analytics_user_attr_func_tkn
    on f.created_date::date = data_analytics_user_attr_func_tkn.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.apex_code_coverage_aggregate f
join data_apex_code_coverage_aggregate
    on f.created_date::date = data_apex_code_coverage_aggregate.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.app_usage_assignment f
join data_app_usage_assignment
    on f.created_date::date = data_app_usage_assignment.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.async_operation_tracker f
join data_async_operation_tracker
    on f.created_date::date = data_async_operation_tracker.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_definition f
join data_attribute_definition
    on f.created_date::date = data_attribute_definition.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_definition_feed f
join data_attribute_definition_feed
    on f.created_date::date = data_attribute_definition_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_definition_history f
join data_attribute_definition_history
    on f.created_date::date = data_attribute_definition_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_picklist f
join data_attribute_picklist
    on f.created_date::date = data_attribute_picklist.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_picklist_feed f
join data_attribute_picklist_feed
    on f.created_date::date = data_attribute_picklist_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_picklist_history f
join data_attribute_picklist_history
    on f.created_date::date = data_attribute_picklist_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_picklist_value f
join data_attribute_picklist_value
    on f.created_date::date = data_attribute_picklist_value.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_picklist_value_feed f
join data_attribute_picklist_value_feed
    on f.created_date::date = data_attribute_picklist_value_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_picklist_value_history f
join data_attribute_picklist_value_history
    on f.created_date::date = data_attribute_picklist_value_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.automation_analytic_c f
join data_automation_analytic_c
    on f.created_date::date = data_automation_analytic_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.business_operations_request_c f
join data_business_operations_request_c
    on f.created_date::date = data_business_operations_request_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.business_operations_request_feed f
join data_business_operations_request_feed
    on f.created_date::date = data_business_operations_request_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.business_operations_request_history f
join data_business_operations_request_history
    on f.created_date::date = data_business_operations_request_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.business_ops_request_c f
join data_business_ops_request_c
    on f.created_date::date = data_business_ops_request_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.calc_affinity_engmt_sgnl f
join data_calc_affinity_engmt_sgnl
    on f.created_date::date = data_calc_affinity_engmt_sgnl.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.calculated_affinity f
join data_calculated_affinity
    on f.created_date::date = data_calculated_affinity.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.calculated_affinity_field f
join data_calculated_affinity_field
    on f.created_date::date = data_calculated_affinity_field.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.calculated_insight_range_bound f
join data_calculated_insight_range_bound
    on f.created_date::date = data_calculated_insight_range_bound.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.campaign f
join data_campaign
    on f.created_date::date = data_campaign.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.card_payment_method f
join data_card_payment_method
    on f.created_date::date = data_card_payment_method.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.case f
join data_case
    on f.created_date::date = data_case.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.case_comment f
join data_case_comment
    on f.created_date::date = data_case_comment.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.case_rel_harmonized_content f
join data_case_rel_harmonized_content
    on f.created_date::date = data_case_rel_harmonized_content.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.case_related_issue f
join data_case_related_issue
    on f.created_date::date = data_case_related_issue.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.case_solution f
join data_case_solution
    on f.created_date::date = data_case_solution.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.chat_report_cr_bot_c f
join data_chat_report_cr_bot_c
    on f.created_date::date = data_chat_report_cr_bot_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.chat_report_cr_custom_label_c f
join data_chat_report_cr_custom_label_c
    on f.created_date::date = data_chat_report_cr_custom_label_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.chat_report_cr_flow_data_c f
join data_chat_report_cr_flow_data_c
    on f.created_date::date = data_chat_report_cr_flow_data_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.chat_report_cr_report_type_c f
join data_chat_report_cr_report_type_c
    on f.created_date::date = data_chat_report_cr_report_type_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.chat_report_cr_skill_based_routing_rule_c f
join data_chat_report_cr_skill_based_routing_rule_c
    on f.created_date::date = data_chat_report_cr_skill_based_routing_rule_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.codesters_codesters_license_c f
join data_codesters_codesters_license_c
    on f.created_date::date = data_codesters_codesters_license_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.codesters_codesters_member_c f
join data_codesters_codesters_member_c
    on f.created_date::date = data_codesters_codesters_member_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.codesters_codesters_organization_c f
join data_codesters_codesters_organization_c
    on f.created_date::date = data_codesters_codesters_organization_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.codesters_codesters_settings_c f
join data_codesters_codesters_settings_c
    on f.created_date::date = data_codesters_codesters_settings_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.codesters_opportunity_license_c f
join data_codesters_opportunity_license_c
    on f.created_date::date = data_codesters_opportunity_license_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.contact f
join data_contact
    on f.created_date::date = data_contact.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.contact_center_bulk_op f
join data_contact_center_bulk_op
    on f.created_date::date = data_contact_center_bulk_op.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.contact_history f
join data_contact_history
    on f.created_date::date = data_contact_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.contract f
join data_contract
    on f.created_date::date = data_contract.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.conversation_api_log f
join data_conversation_api_log
    on f.created_date::date = data_conversation_api_log.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.conversation_api_log_obj_sum f
join data_conversation_api_log_obj_sum
    on f.created_date::date = data_conversation_api_log_obj_sum.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo f
join data_credit_memo
    on f.created_date::date = data_credit_memo.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo_feed f
join data_credit_memo_feed
    on f.created_date::date = data_credit_memo_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo_history f
join data_credit_memo_history
    on f.created_date::date = data_credit_memo_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo_inv_application f
join data_credit_memo_inv_application
    on f.created_date::date = data_credit_memo_inv_application.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo_inv_application_feed f
join data_credit_memo_inv_application_feed
    on f.created_date::date = data_credit_memo_inv_application_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo_inv_application_history f
join data_credit_memo_inv_application_history
    on f.created_date::date = data_credit_memo_inv_application_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo_line f
join data_credit_memo_line
    on f.created_date::date = data_credit_memo_line.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo_line_feed f
join data_credit_memo_line_feed
    on f.created_date::date = data_credit_memo_line_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo_line_history f
join data_credit_memo_line_history
    on f.created_date::date = data_credit_memo_line_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.dashboard_component_localization f
join data_dashboard_component_localization
    on f.created_date::date = data_dashboard_component_localization.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.dashboard_localization f
join data_dashboard_localization
    on f.created_date::date = data_dashboard_localization.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_assessment_field_metric f
join data_data_assessment_field_metric
    on f.created_date::date = data_data_assessment_field_metric.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_assessment_metric f
join data_data_assessment_metric
    on f.created_date::date = data_data_assessment_metric.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_assessment_value_metric f
join data_data_assessment_value_metric
    on f.created_date::date = data_data_assessment_value_metric.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_content_lens_source f
join data_data_content_lens_source
    on f.created_date::date = data_data_content_lens_source.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_content_lens_source_feed f
join data_data_content_lens_source_feed
    on f.created_date::date = data_data_content_lens_source_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_content_lens_source_history f
join data_data_content_lens_source_history
    on f.created_date::date = data_data_content_lens_source_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_harmonized_model_obj_ref f
join data_data_harmonized_model_obj_ref
    on f.created_date::date = data_data_harmonized_model_obj_ref.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_knowledge_space f
join data_data_knowledge_space
    on f.created_date::date = data_data_knowledge_space.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_knowledge_space_session f
join data_data_knowledge_space_session
    on f.created_date::date = data_data_knowledge_space_session.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_knowledge_src_file_ref f
join data_data_knowledge_src_file_ref
    on f.created_date::date = data_data_knowledge_src_file_ref.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_obj_secondary_index f
join data_data_obj_secondary_index
    on f.created_date::date = data_data_obj_secondary_index.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_obj_secondary_index_feed f
join data_data_obj_secondary_index_feed
    on f.created_date::date = data_data_obj_secondary_index_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_obj_secondary_index_history f
join data_data_obj_secondary_index_history
    on f.created_date::date = data_data_obj_secondary_index_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_quick_attribute f
join data_data_quick_attribute
    on f.created_date::date = data_data_quick_attribute.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_quick_attribute_feed f
join data_data_quick_attribute_feed
    on f.created_date::date = data_data_quick_attribute_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_quick_attribute_history f
join data_data_quick_attribute_history
    on f.created_date::date = data_data_quick_attribute_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_space f
join data_data_space
    on f.created_date::date = data_data_space.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_space_feed f
join data_data_space_feed
    on f.created_date::date = data_data_space_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_space_history f
join data_data_space_history
    on f.created_date::date = data_data_space_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.digital_wallet f
join data_digital_wallet
    on f.created_date::date = data_digital_wallet.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.doc_generation_query_result f
join data_doc_generation_query_result
    on f.created_date::date = data_doc_generation_query_result.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.doc_generation_query_result_feed f
join data_doc_generation_query_result_feed
    on f.created_date::date = data_doc_generation_query_result_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.doc_generation_query_result_history f
join data_doc_generation_query_result_history
    on f.created_date::date = data_doc_generation_query_result_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.document_generation_process f
join data_document_generation_process
    on f.created_date::date = data_document_generation_process.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.engagement_signal f
join data_engagement_signal
    on f.created_date::date = data_engagement_signal.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.engagement_signal_cmpnd_metric f
join data_engagement_signal_cmpnd_metric
    on f.created_date::date = data_engagement_signal_cmpnd_metric.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.engagement_signal_feed f
join data_engagement_signal_feed
    on f.created_date::date = data_engagement_signal_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.engagement_signal_history f
join data_engagement_signal_history
    on f.created_date::date = data_engagement_signal_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.engagement_signal_metric f
join data_engagement_signal_metric
    on f.created_date::date = data_engagement_signal_metric.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.epic_c f
join data_epic_c
    on f.created_date::date = data_epic_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.epic_feed f
join data_epic_feed
    on f.created_date::date = data_epic_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.epic_history f
join data_epic_history
    on f.created_date::date = data_epic_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.flow_personal_configuration_c f
join data_flow_personal_configuration_c
    on f.created_date::date = data_flow_personal_configuration_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.flow_table_view_definition_c f
join data_flow_table_view_definition_c
    on f.created_date::date = data_flow_table_view_definition_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.forecasting_submission f
join data_forecasting_submission
    on f.created_date::date = data_forecasting_submission.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.forecasting_submission_item f
join data_forecasting_submission_item
    on f.created_date::date = data_forecasting_submission_item.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.goal_assignment f
join data_goal_assignment
    on f.created_date::date = data_goal_assignment.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.goal_assignment_feed f
join data_goal_assignment_feed
    on f.created_date::date = data_goal_assignment_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.goal_assignment_history f
join data_goal_assignment_history
    on f.created_date::date = data_goal_assignment_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.goal_assignment_recommendation f
join data_goal_assignment_recommendation
    on f.created_date::date = data_goal_assignment_recommendation.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.goal_definition f
join data_goal_definition
    on f.created_date::date = data_goal_definition.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.goal_definition_feed f
join data_goal_definition_feed
    on f.created_date::date = data_goal_definition_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.goal_definition_history f
join data_goal_definition_history
    on f.created_date::date = data_goal_definition_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.incp_incident_lv_fields_c f
join data_incp_incident_lv_fields_c
    on f.created_date::date = data_incp_incident_lv_fields_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.incp_time_zone_selection_c f
join data_incp_time_zone_selection_c
    on f.created_date::date = data_incp_time_zone_selection_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.invoice f
join data_invoice
    on f.created_date::date = data_invoice.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.invoice_feed f
join data_invoice_feed
    on f.created_date::date = data_invoice_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.invoice_history f
join data_invoice_history
    on f.created_date::date = data_invoice_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.invoice_line f
join data_invoice_line
    on f.created_date::date = data_invoice_line.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.invoice_line_feed f
join data_invoice_line_feed
    on f.created_date::date = data_invoice_line_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.invoice_line_history f
join data_invoice_line_history
    on f.created_date::date = data_invoice_line_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_account_c f
join data_lcom_account_c
    on f.created_date::date = data_lcom_account_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_account_feed f
join data_lcom_account_feed
    on f.created_date::date = data_lcom_account_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_license_c f
join data_lcom_license_c
    on f.created_date::date = data_lcom_license_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_license_feed f
join data_lcom_license_feed
    on f.created_date::date = data_lcom_license_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_license_site_c f
join data_lcom_license_site_c
    on f.created_date::date = data_lcom_license_site_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_license_site_feed f
join data_lcom_license_site_feed
    on f.created_date::date = data_lcom_license_site_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_member_c f
join data_lcom_member_c
    on f.created_date::date = data_lcom_member_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_member_feed f
join data_lcom_member_feed
    on f.created_date::date = data_lcom_member_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_opportunity_site_c f
join data_lcom_opportunity_site_c
    on f.created_date::date = data_lcom_opportunity_site_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_opportunity_term_c f
join data_lcom_opportunity_term_c
    on f.created_date::date = data_lcom_opportunity_term_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_opportunity_term_feed f
join data_lcom_opportunity_term_feed
    on f.created_date::date = data_lcom_opportunity_term_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_opportunity_term_history f
join data_lcom_opportunity_term_history
    on f.created_date::date = data_lcom_opportunity_term_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_order_c f
join data_lcom_order_c
    on f.created_date::date = data_lcom_order_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_order_feed f
join data_lcom_order_feed
    on f.created_date::date = data_lcom_order_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_order_line_c f
join data_lcom_order_line_c
    on f.created_date::date = data_lcom_order_line_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_order_line_feed f
join data_lcom_order_line_feed
    on f.created_date::date = data_lcom_order_line_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_order_modification_c f
join data_lcom_order_modification_c
    on f.created_date::date = data_lcom_order_modification_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_order_modification_feed f
join data_lcom_order_modification_feed
    on f.created_date::date = data_lcom_order_modification_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_organization_c f
join data_lcom_organization_c
    on f.created_date::date = data_lcom_organization_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_organization_feed f
join data_lcom_organization_feed
    on f.created_date::date = data_lcom_organization_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_suite_c f
join data_lcom_suite_c
    on f.created_date::date = data_lcom_suite_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_suite_feed f
join data_lcom_suite_feed
    on f.created_date::date = data_lcom_suite_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_term_c f
join data_lcom_term_c
    on f.created_date::date = data_lcom_term_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_term_feed f
join data_lcom_term_feed
    on f.created_date::date = data_lcom_term_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lead f
join data_lead
    on f.created_date::date = data_lead.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lead_status_c f
join data_lead_status_c
    on f.created_date::date = data_lead_status_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.learning_com_c f
join data_learning_com_c
    on f.created_date::date = data_learning_com_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.learning_com_district_license_c f
join data_learning_com_district_license_c
    on f.created_date::date = data_learning_com_district_license_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.learning_com_district_license_history f
join data_learning_com_district_license_history
    on f.created_date::date = data_learning_com_district_license_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.learning_com_order_c f
join data_learning_com_order_c
    on f.created_date::date = data_learning_com_order_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.learning_com_school_license_c f
join data_learning_com_school_license_c
    on f.created_date::date = data_learning_com_school_license_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.learning_com_school_license_history f
join data_learning_com_school_license_history
    on f.created_date::date = data_learning_com_school_license_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.market_segment f
join data_market_segment
    on f.created_date::date = data_market_segment.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.market_segment_activation f
join data_market_segment_activation
    on f.created_date::date = data_market_segment_activation.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.market_segment_activation_feed f
join data_market_segment_activation_feed
    on f.created_date::date = data_market_segment_activation_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.market_segment_activation_history f
join data_market_segment_activation_history
    on f.created_date::date = data_market_segment_activation_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.market_segment_feed f
join data_market_segment_feed
    on f.created_date::date = data_market_segment_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.market_segment_history f
join data_market_segment_history
    on f.created_date::date = data_market_segment_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mkt_sgmnt_actvtn_aud_attribute f
join data_mkt_sgmnt_actvtn_aud_attribute
    on f.created_date::date = data_mkt_sgmnt_actvtn_aud_attribute.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mkt_sgmnt_actvtn_contact_point f
join data_mkt_sgmnt_actvtn_contact_point
    on f.created_date::date = data_mkt_sgmnt_actvtn_contact_point.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mkt_sgmt_actv_contact_pt_field f
join data_mkt_sgmt_actv_contact_pt_field
    on f.created_date::date = data_mkt_sgmt_actv_contact_pt_field.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mkt_sgmt_actv_contact_pt_src f
join data_mkt_sgmt_actv_contact_pt_src
    on f.created_date::date = data_mkt_sgmt_actv_contact_pt_src.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mkt_sgmt_actv_data_model_fld f
join data_mkt_sgmt_actv_data_model_fld
    on f.created_date::date = data_mkt_sgmt_actv_data_model_fld.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mkt_sgmt_actv_data_source f
join data_mkt_sgmt_actv_data_source
    on f.created_date::date = data_mkt_sgmt_actv_data_source.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.ml_intent_utterance_suggestion f
join data_ml_intent_utterance_suggestion
    on f.created_date::date = data_ml_intent_utterance_suggestion.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mlmodel f
join data_mlmodel
    on f.created_date::date = data_mlmodel.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mlmodel_factor f
join data_mlmodel_factor
    on f.created_date::date = data_mlmodel_factor.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mlmodel_factor_component f
join data_mlmodel_factor_component
    on f.created_date::date = data_mlmodel_factor_component.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mlmodel_metric f
join data_mlmodel_metric
    on f.created_date::date = data_mlmodel_metric.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.nps_survey_responses_c f
join data_nps_survey_responses_c
    on f.created_date::date = data_nps_survey_responses_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.object_from_email_accepted_fields_c f
join data_object_from_email_accepted_fields_c
    on f.created_date::date = data_object_from_email_accepted_fields_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.object_from_email_default_fields_c f
join data_object_from_email_default_fields_c
    on f.created_date::date = data_object_from_email_default_fields_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.object_milestone_pause_time f
join data_object_milestone_pause_time
    on f.created_date::date = data_object_milestone_pause_time.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_component_error_log f
join data_omni_component_error_log
    on f.created_date::date = data_omni_component_error_log.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_component_error_log_feed f
join data_omni_component_error_log_feed
    on f.created_date::date = data_omni_component_error_log_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_data_pack f
join data_omni_data_pack
    on f.created_date::date = data_omni_data_pack.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_data_pack_feed f
join data_omni_data_pack_feed
    on f.created_date::date = data_omni_data_pack_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_data_transform f
join data_omni_data_transform
    on f.created_date::date = data_omni_data_transform.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_data_transform_item f
join data_omni_data_transform_item
    on f.created_date::date = data_omni_data_transform_item.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_esignature_template f
join data_omni_esignature_template
    on f.created_date::date = data_omni_esignature_template.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_global_auto_number f
join data_omni_global_auto_number
    on f.created_date::date = data_omni_global_auto_number.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_global_auto_number_feed f
join data_omni_global_auto_number_feed
    on f.created_date::date = data_omni_global_auto_number_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_process f
join data_omni_process
    on f.created_date::date = data_omni_process.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_process_compilation f
join data_omni_process_compilation
    on f.created_date::date = data_omni_process_compilation.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_process_element f
join data_omni_process_element
    on f.created_date::date = data_omni_process_element.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_process_feed f
join data_omni_process_feed
    on f.created_date::date = data_omni_process_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_process_transient_data f
join data_omni_process_transient_data
    on f.created_date::date = data_omni_process_transient_data.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_process_transient_data_feed f
join data_omni_process_transient_data_feed
    on f.created_date::date = data_omni_process_transient_data_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_script_saved_session f
join data_omni_script_saved_session
    on f.created_date::date = data_omni_script_saved_session.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_script_saved_session_feed f
join data_omni_script_saved_session_feed
    on f.created_date::date = data_omni_script_saved_session_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_ui_card f
join data_omni_ui_card
    on f.created_date::date = data_omni_ui_card.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_ui_card_feed f
join data_omni_ui_card_feed
    on f.created_date::date = data_omni_ui_card_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.operating_hours f
join data_operating_hours
    on f.created_date::date = data_operating_hours.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.operating_hours_feed f
join data_operating_hours_feed
    on f.created_date::date = data_operating_hours_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.operating_hours_history f
join data_operating_hours_history
    on f.created_date::date = data_operating_hours_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.operating_hours_holiday f
join data_operating_hours_holiday
    on f.created_date::date = data_operating_hours_holiday.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.operating_hours_holiday_feed f
join data_operating_hours_holiday_feed
    on f.created_date::date = data_operating_hours_holiday_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.operating_hours_holiday_history f
join data_operating_hours_holiday_history
    on f.created_date::date = data_operating_hours_holiday_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.opportunity f
join data_opportunity
    on f.created_date::date = data_opportunity.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.opportunity_line_item f
join data_opportunity_line_item
    on f.created_date::date = data_opportunity_line_item.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.order f
join data_order
    on f.created_date::date = data_order.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.order_detail_confirmation_c f
join data_order_detail_confirmation_c
    on f.created_date::date = data_order_detail_confirmation_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.order_detail_confirmation_history f
join data_order_detail_confirmation_history
    on f.created_date::date = data_order_detail_confirmation_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.order_item f
join data_order_item
    on f.created_date::date = data_order_item.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.organization f
join data_organization
    on f.created_date::date = data_organization.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.payment f
join data_payment
    on f.created_date::date = data_payment.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.payment_auth_adjustment f
join data_payment_auth_adjustment
    on f.created_date::date = data_payment_auth_adjustment.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.payment_authorization f
join data_payment_authorization
    on f.created_date::date = data_payment_authorization.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.payment_feed f
join data_payment_feed
    on f.created_date::date = data_payment_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.payment_gateway f
join data_payment_gateway
    on f.created_date::date = data_payment_gateway.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.payment_gateway_log f
join data_payment_gateway_log
    on f.created_date::date = data_payment_gateway_log.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.payment_group f
join data_payment_group
    on f.created_date::date = data_payment_group.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.payment_line_invoice f
join data_payment_line_invoice
    on f.created_date::date = data_payment_line_invoice.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.personalization_schema f
join data_personalization_schema
    on f.created_date::date = data_personalization_schema.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.pricebook_2 f
join data_pricebook_2
    on f.created_date::date = data_pricebook_2.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.pricebook_entry f
join data_pricebook_entry
    on f.created_date::date = data_pricebook_entry.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_2 f
join data_product_2
    on f.created_date::date = data_product_2.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_catalog f
join data_product_catalog
    on f.created_date::date = data_product_catalog.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_catalog_feed f
join data_product_catalog_feed
    on f.created_date::date = data_product_catalog_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_catalog_history f
join data_product_catalog_history
    on f.created_date::date = data_product_catalog_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_category f
join data_product_category
    on f.created_date::date = data_product_category.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_category_feed f
join data_product_category_feed
    on f.created_date::date = data_product_category_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_category_history f
join data_product_category_history
    on f.created_date::date = data_product_category_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_category_product f
join data_product_category_product
    on f.created_date::date = data_product_category_product.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_category_product_history f
join data_product_category_product_history
    on f.created_date::date = data_product_category_product_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_component_group f
join data_product_component_group
    on f.created_date::date = data_product_component_group.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_component_group_feed f
join data_product_component_group_feed
    on f.created_date::date = data_product_component_group_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_component_group_history f
join data_product_component_group_history
    on f.created_date::date = data_product_component_group_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_config_flow_assignment f
join data_product_config_flow_assignment
    on f.created_date::date = data_product_config_flow_assignment.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_configuration_flow f
join data_product_configuration_flow
    on f.created_date::date = data_product_configuration_flow.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_configuration_flow_feed f
join data_product_configuration_flow_feed
    on f.created_date::date = data_product_configuration_flow_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_configuration_flow_history f
join data_product_configuration_flow_history
    on f.created_date::date = data_product_configuration_flow_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_related_component f
join data_product_related_component
    on f.created_date::date = data_product_related_component.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_relationship_type f
join data_product_relationship_type
    on f.created_date::date = data_product_relationship_type.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_selling_model f
join data_product_selling_model
    on f.created_date::date = data_product_selling_model.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_selling_model_feed f
join data_product_selling_model_feed
    on f.created_date::date = data_product_selling_model_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_selling_model_history f
join data_product_selling_model_history
    on f.created_date::date = data_product_selling_model_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_selling_model_option f
join data_product_selling_model_option
    on f.created_date::date = data_product_selling_model_option.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.profile f
join data_profile
    on f.created_date::date = data_profile.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.prompt_action f
join data_prompt_action
    on f.created_date::date = data_prompt_action.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.prompt_error f
join data_prompt_error
    on f.created_date::date = data_prompt_error.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.proration_policy f
join data_proration_policy
    on f.created_date::date = data_proration_policy.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.rcsfl_admin_setting_c f
join data_rcsfl_admin_setting_c
    on f.created_date::date = data_rcsfl_admin_setting_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.rcsfl_ai_notes_c f
join data_rcsfl_ai_notes_c
    on f.created_date::date = data_rcsfl_ai_notes_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.rcsfl_ring_central_webinar_token_c f
join data_rcsfl_ring_central_webinar_token_c
    on f.created_date::date = data_rcsfl_ring_central_webinar_token_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.record_type f
join data_record_type
    on f.created_date::date = data_record_type.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.refund f
join data_refund
    on f.created_date::date = data_refund.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.refund_line_payment f
join data_refund_line_payment
    on f.created_date::date = data_refund_line_payment.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.revenue_async_operation f
join data_revenue_async_operation
    on f.created_date::date = data_revenue_async_operation.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.revenue_transaction_error_log f
join data_revenue_transaction_error_log
    on f.created_date::date = data_revenue_transaction_error_log.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sbqq_field_metadata_c f
join data_sbqq_field_metadata_c
    on f.created_date::date = data_sbqq_field_metadata_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sbqq_product_option_c f
join data_sbqq_product_option_c
    on f.created_date::date = data_sbqq_product_option_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sbqq_quote_c f
join data_sbqq_quote_c
    on f.created_date::date = data_sbqq_quote_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sbqq_quote_line_c f
join data_sbqq_quote_line_c
    on f.created_date::date = data_sbqq_quote_line_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sbqq_quote_line_group_c f
join data_sbqq_quote_line_group_c
    on f.created_date::date = data_sbqq_quote_line_group_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sender_email_address f
join data_sender_email_address
    on f.created_date::date = data_sender_email_address.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.service_and_training_request_c f
join data_service_and_training_request_c
    on f.created_date::date = data_service_and_training_request_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.service_and_training_request_feed f
join data_service_and_training_request_feed
    on f.created_date::date = data_service_and_training_request_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.service_and_training_request_history f
join data_service_and_training_request_history
    on f.created_date::date = data_service_and_training_request_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.setup_assistant_step f
join data_setup_assistant_step
    on f.created_date::date = data_setup_assistant_step.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sfdc_partner_sbscr_offer f
join data_sfdc_partner_sbscr_offer
    on f.created_date::date = data_sfdc_partner_sbscr_offer.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sfdc_partner_sbscr_offer_history f
join data_sfdc_partner_sbscr_offer_history
    on f.created_date::date = data_sfdc_partner_sbscr_offer_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sfdc_partner_sbscr_offer_item f
join data_sfdc_partner_sbscr_offer_item
    on f.created_date::date = data_sfdc_partner_sbscr_offer_item.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.slack_channel_related_record f
join data_slack_channel_related_record
    on f.created_date::date = data_slack_channel_related_record.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.state_profile_c f
join data_state_profile_c
    on f.created_date::date = data_state_profile_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.switches_c f
join data_switches_c
    on f.created_date::date = data_switches_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.team_c f
join data_team_c
    on f.created_date::date = data_team_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.team_feed f
join data_team_feed
    on f.created_date::date = data_team_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.team_history f
join data_team_history
    on f.created_date::date = data_team_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.team_member_c f
join data_team_member_c
    on f.created_date::date = data_team_member_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.team_member_feed f
join data_team_member_feed
    on f.created_date::date = data_team_member_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.team_member_history f
join data_team_member_history
    on f.created_date::date = data_team_member_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.time_slot f
join data_time_slot
    on f.created_date::date = data_time_slot.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.time_slot_history f
join data_time_slot_history
    on f.created_date::date = data_time_slot_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.training_session_c f
join data_training_session_c
    on f.created_date::date = data_training_session_c.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.training_session_feed f
join data_training_session_feed
    on f.created_date::date = data_training_session_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.unit_of_measure f
join data_unit_of_measure
    on f.created_date::date = data_unit_of_measure.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.unstructured_storage_space f
join data_unstructured_storage_space
    on f.created_date::date = data_unstructured_storage_space.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.user f
join data_user
    on f.created_date::date = data_user.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.user_history f
join data_user_history
    on f.created_date::date = data_user_history.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.user_prov_account f
join data_user_prov_account
    on f.created_date::date = data_user_prov_account.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.user_prov_account_staging f
join data_user_prov_account_staging
    on f.created_date::date = data_user_prov_account_staging.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.user_prov_mock_target f
join data_user_prov_mock_target
    on f.created_date::date = data_user_prov_mock_target.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.user_provisioning_log f
join data_user_provisioning_log
    on f.created_date::date = data_user_provisioning_log.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.user_provisioning_request f
join data_user_provisioning_request
    on f.created_date::date = data_user_provisioning_request.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.video_call f
join data_video_call
    on f.created_date::date = data_video_call.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.video_call_feed f
join data_video_call_feed
    on f.created_date::date = data_video_call_feed.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.video_call_participant f
join data_video_call_participant
    on f.created_date::date = data_video_call_participant.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.video_call_recording f
join data_video_call_recording
    on f.created_date::date = data_video_call_recording.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.voice_call_recording f
join data_voice_call_recording
    on f.created_date::date = data_voice_call_recording.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.voice_chnl_interaction_event f
join data_voice_chnl_interaction_event
    on f.created_date::date = data_voice_chnl_interaction_event.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.voice_chnl_intrctn_dtl_event f
join data_voice_chnl_intrctn_dtl_event
    on f.created_date::date = data_voice_chnl_intrctn_dtl_event.max_created_date
group by all
union all
select
    schema_name,
    table_name,
    total_rows,
    max_created_date,
    count(1) as changed_on_max_created_date
from rawdata.fivetran_salesforce.web_link f
join data_web_link
    on f.created_date::date = data_web_link.max_created_date
group by all
