{{ config(materialized='view', bind=False) }}

with
/*==============================================================================================*/
/*====================================  HUBSPOT  ===============================================*/
/*==============================================================================================*/
data_association_type as (
    select
        'fivetran_hubspot' as schema_name,
        'association_type' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.association_type
)
,
data_company as (
    select
        'fivetran_hubspot' as schema_name,
        'company' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(property_createdate)::date as max_created_date
    from rawdata.fivetran_hubspot.company
)
,
data_company_company as (
    select
        'fivetran_hubspot' as schema_name,
        'company_company' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.company_company
)
,
data_contact_hubspot as (
    select
        'fivetran_hubspot' as schema_name,
        'contact' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(property_createdate)::date as max_created_date
    from rawdata.fivetran_hubspot.contact
)
,
data_contact_company as (
    select
        'fivetran_hubspot' as schema_name,
        'contact_company' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.contact_company
)
,
data_deal as (
    select
        'fivetran_hubspot' as schema_name,
        'deal' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(property_hs_createdate)::date as max_created_date
    from rawdata.fivetran_hubspot.deal
)
,
data_deal_company as (
    select
        'fivetran_hubspot' as schema_name,
        'deal_company' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.deal_company
)
,
data_deal_contact as (
    select
        'fivetran_hubspot' as schema_name,
        'deal_contact' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.deal_contact
)
,
data_deal_pipeline as (
    select
        'fivetran_hubspot' as schema_name,
        'deal_pipeline' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.deal_pipeline
)
,
data_deal_pipeline_stage as (
    select
        'fivetran_hubspot' as schema_name,
        'deal_pipeline_stage' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.deal_pipeline_stage
)
,
data_deal_stage as (
    select
        'fivetran_hubspot' as schema_name,
        'deal_stage' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.deal_stage
)
,
data_invoice_hubspot as (
    select
        'fivetran_hubspot' as schema_name,
        'invoice' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(property_hs_createdate)::date as max_created_date
    from rawdata.fivetran_hubspot.invoice
)
,
data_invoice_company as (
    select
        'fivetran_hubspot' as schema_name,
        'invoice_company' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.invoice_company
)
,
data_invoice_contact as (
    select
        'fivetran_hubspot' as schema_name,
        'invoice_contact' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.invoice_contact
)
,
data_invoice_deal as (
    select
        'fivetran_hubspot' as schema_name,
        'invoice_deal' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.invoice_deal
)
,
data_invoice_line_item as (
    select
        'fivetran_hubspot' as schema_name,
        'invoice_line_item' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.invoice_line_item
)
,
data_line_item as (
    select
        'fivetran_hubspot' as schema_name,
        'line_item' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(property_createdate)::date as max_created_date
    from rawdata.fivetran_hubspot.line_item
)
,
data_line_item_deal as (
    select
        'fivetran_hubspot' as schema_name,
        'line_item_deal' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.line_item_deal
)
,
data_payment_hubspot as (
    select
        'fivetran_hubspot' as schema_name,
        'payment' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(property_hs_createdate)::date as max_created_date
    from rawdata.fivetran_hubspot.payment
)
,
data_payment_company as (
    select
        'fivetran_hubspot' as schema_name,
        'payment_company' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.payment_company
)
,
data_payment_contact as (
    select
        'fivetran_hubspot' as schema_name,
        'payment_contact' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.payment_contact
)
,
data_payment_deal as (
    select
        'fivetran_hubspot' as schema_name,
        'payment_deal' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.payment_deal
)
,
data_payment_invoice as (
    select
        'fivetran_hubspot' as schema_name,
        'payment_invoice' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.payment_invoice
)
,
data_payment_line_item as (
    select
        'fivetran_hubspot' as schema_name,
        'payment_line_item' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_hubspot.payment_line_item
)
,
data_product as (
    select
        'fivetran_hubspot' as schema_name,
        'product' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(property_createdate)::date as max_created_date
    from rawdata.fivetran_hubspot.product
)
,
/*==============================================================================================*/
/*====================================  SALESFORCE ===============================================*/
/*==============================================================================================*/
data_abn_experiment as (
    select
        'fivetran_salesforce' as schema_name,
        'abn_experiment' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.abn_experiment
)
,
data_abn_experiment_cohort as (
    select
        'fivetran_salesforce' as schema_name,
        'abn_experiment_cohort' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.abn_experiment_cohort
)
,
data_abn_experiment_cohort_attr_val as (
    select
        'fivetran_salesforce' as schema_name,
        'abn_experiment_cohort_attr_val' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.abn_experiment_cohort_attr_val
)
,
data_abn_experiment_engmt_sgnl_mtrc as (
    select
        'fivetran_salesforce' as schema_name,
        'abn_experiment_engmt_sgnl_mtrc' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.abn_experiment_engmt_sgnl_mtrc
)
,
data_account as (
    select
        'fivetran_salesforce' as schema_name,
        'account' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.account
)
,
data_account_brand as (
    select
        'fivetran_salesforce' as schema_name,
        'account_brand' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.account_brand
)
,
data_account_relation_c as (
    select
        'fivetran_salesforce' as schema_name,
        'account_relation_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.account_relation_c
)
,
data_account_relation_history as (
    select
        'fivetran_salesforce' as schema_name,
        'account_relation_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.account_relation_history
)
,
data_activation_target as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_target' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_target
)
,
data_activation_target_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_target_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_target_feed
)
,
data_activation_target_history as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_target_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_target_history
)
,
data_activation_target_platform as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_target_platform' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_target_platform
)
,
data_activation_target_platform_history as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_target_platform_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_target_platform_history
)
,
data_activation_target_secure_ftp as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_target_secure_ftp' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_target_secure_ftp
)
,
data_activation_trgt_int_org_access as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_trgt_int_org_access' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_trgt_int_org_access
)
,
data_activation_trgt_int_org_access_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_trgt_int_org_access_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_trgt_int_org_access_feed
)
,
data_activation_trgt_int_org_access_history as (
    select
        'fivetran_salesforce' as schema_name,
        'activation_trgt_int_org_access_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activation_trgt_int_org_access_history
)
,
data_activity_roll_up_c as (
    select
        'fivetran_salesforce' as schema_name,
        'activity_roll_up_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activity_roll_up_c
)
,
data_activity_roll_up_history as (
    select
        'fivetran_salesforce' as schema_name,
        'activity_roll_up_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.activity_roll_up_history
)
,
data_actv_tgt_platform_field_value as (
    select
        'fivetran_salesforce' as schema_name,
        'actv_tgt_platform_field_value' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.actv_tgt_platform_field_value
)
,
data_actv_tgt_platform_field_value_history as (
    select
        'fivetran_salesforce' as schema_name,
        'actv_tgt_platform_field_value_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.actv_tgt_platform_field_value_history
)
,
data_agileed_connect_link_data_problem_report_c as (
    select
        'fivetran_salesforce' as schema_name,
        'agileed_connect_link_data_problem_report_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.agileed_connect_link_data_problem_report_c
)
,
data_agileed_fieldmapping_c as (
    select
        'fivetran_salesforce' as schema_name,
        'agileed_fieldmapping_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.agileed_fieldmapping_c
)
,
data_ai_job_run as (
    select
        'fivetran_salesforce' as schema_name,
        'ai_job_run' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.ai_job_run
)
,
data_alternative_payment_method as (
    select
        'fivetran_salesforce' as schema_name,
        'alternative_payment_method' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.alternative_payment_method
)
,
data_analytics_user_attr_func_tkn as (
    select
        'fivetran_salesforce' as schema_name,
        'analytics_user_attr_func_tkn' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.analytics_user_attr_func_tkn
)
,
data_apex_code_coverage_aggregate as (
    select
        'fivetran_salesforce' as schema_name,
        'apex_code_coverage_aggregate' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.apex_code_coverage_aggregate
)
,
data_app_usage_assignment as (
    select
        'fivetran_salesforce' as schema_name,
        'app_usage_assignment' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.app_usage_assignment
)
,
data_async_operation_tracker as (
    select
        'fivetran_salesforce' as schema_name,
        'async_operation_tracker' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.async_operation_tracker
)
,
data_attribute_definition as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_definition' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_definition
)
,
data_attribute_definition_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_definition_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_definition_feed
)
,
data_attribute_definition_history as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_definition_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_definition_history
)
,
data_attribute_picklist as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_picklist' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_picklist
)
,
data_attribute_picklist_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_picklist_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_picklist_feed
)
,
data_attribute_picklist_history as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_picklist_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_picklist_history
)
,
data_attribute_picklist_value as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_picklist_value' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_picklist_value
)
,
data_attribute_picklist_value_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_picklist_value_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_picklist_value_feed
)
,
data_attribute_picklist_value_history as (
    select
        'fivetran_salesforce' as schema_name,
        'attribute_picklist_value_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.attribute_picklist_value_history
)
,
data_automation_analytic_c as (
    select
        'fivetran_salesforce' as schema_name,
        'automation_analytic_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.automation_analytic_c
)
,
data_business_operations_request_c as (
    select
        'fivetran_salesforce' as schema_name,
        'business_operations_request_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.business_operations_request_c
)
,
data_business_operations_request_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'business_operations_request_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.business_operations_request_feed
)
,
data_business_operations_request_history as (
    select
        'fivetran_salesforce' as schema_name,
        'business_operations_request_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.business_operations_request_history
)
,
data_business_ops_request_c as (
    select
        'fivetran_salesforce' as schema_name,
        'business_ops_request_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.business_ops_request_c
)
,
data_calc_affinity_engmt_sgnl as (
    select
        'fivetran_salesforce' as schema_name,
        'calc_affinity_engmt_sgnl' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.calc_affinity_engmt_sgnl
)
,
data_calculated_affinity as (
    select
        'fivetran_salesforce' as schema_name,
        'calculated_affinity' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.calculated_affinity
)
,
data_calculated_affinity_field as (
    select
        'fivetran_salesforce' as schema_name,
        'calculated_affinity_field' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.calculated_affinity_field
)
,
data_calculated_insight_range_bound as (
    select
        'fivetran_salesforce' as schema_name,
        'calculated_insight_range_bound' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.calculated_insight_range_bound
)
,
data_campaign as (
    select
        'fivetran_salesforce' as schema_name,
        'campaign' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.campaign
)
,
data_card_payment_method as (
    select
        'fivetran_salesforce' as schema_name,
        'card_payment_method' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.card_payment_method
)
,
data_case as (
    select
        'fivetran_salesforce' as schema_name,
        'case' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.case
)
,
data_case_comment as (
    select
        'fivetran_salesforce' as schema_name,
        'case_comment' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.case_comment
)
,
data_case_rel_harmonized_content as (
    select
        'fivetran_salesforce' as schema_name,
        'case_rel_harmonized_content' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.case_rel_harmonized_content
)
,
data_case_related_issue as (
    select
        'fivetran_salesforce' as schema_name,
        'case_related_issue' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.case_related_issue
)
,
data_case_solution as (
    select
        'fivetran_salesforce' as schema_name,
        'case_solution' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.case_solution
)
,
data_chat_report_cr_bot_c as (
    select
        'fivetran_salesforce' as schema_name,
        'chat_report_cr_bot_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.chat_report_cr_bot_c
)
,
data_chat_report_cr_custom_label_c as (
    select
        'fivetran_salesforce' as schema_name,
        'chat_report_cr_custom_label_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.chat_report_cr_custom_label_c
)
,
data_chat_report_cr_flow_data_c as (
    select
        'fivetran_salesforce' as schema_name,
        'chat_report_cr_flow_data_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.chat_report_cr_flow_data_c
)
,
data_chat_report_cr_report_type_c as (
    select
        'fivetran_salesforce' as schema_name,
        'chat_report_cr_report_type_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.chat_report_cr_report_type_c
)
,
data_chat_report_cr_skill_based_routing_rule_c as (
    select
        'fivetran_salesforce' as schema_name,
        'chat_report_cr_skill_based_routing_rule_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.chat_report_cr_skill_based_routing_rule_c
)
,
data_codesters_codesters_license_c as (
    select
        'fivetran_salesforce' as schema_name,
        'codesters_codesters_license_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.codesters_codesters_license_c
)
,
data_codesters_codesters_member_c as (
    select
        'fivetran_salesforce' as schema_name,
        'codesters_codesters_member_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.codesters_codesters_member_c
)
,
data_codesters_codesters_organization_c as (
    select
        'fivetran_salesforce' as schema_name,
        'codesters_codesters_organization_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.codesters_codesters_organization_c
)
,
data_codesters_codesters_settings_c as (
    select
        'fivetran_salesforce' as schema_name,
        'codesters_codesters_settings_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.codesters_codesters_settings_c
)
,
data_codesters_opportunity_license_c as (
    select
        'fivetran_salesforce' as schema_name,
        'codesters_opportunity_license_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.codesters_opportunity_license_c
)
,
data_contact as (
    select
        'fivetran_salesforce' as schema_name,
        'contact' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.contact
)
,
data_contact_center_bulk_op as (
    select
        'fivetran_salesforce' as schema_name,
        'contact_center_bulk_op' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.contact_center_bulk_op
)
,
data_contact_history as (
    select
        'fivetran_salesforce' as schema_name,
        'contact_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.contact_history
)
,
data_contract as (
    select
        'fivetran_salesforce' as schema_name,
        'contract' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.contract
)
,
data_conversation_api_log as (
    select
        'fivetran_salesforce' as schema_name,
        'conversation_api_log' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.conversation_api_log
)
,
data_conversation_api_log_obj_sum as (
    select
        'fivetran_salesforce' as schema_name,
        'conversation_api_log_obj_sum' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.conversation_api_log_obj_sum
)
,
data_credit_memo as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo
)
,
data_credit_memo_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo_feed
)
,
data_credit_memo_history as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo_history
)
,
data_credit_memo_inv_application as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo_inv_application' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo_inv_application
)
,
data_credit_memo_inv_application_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo_inv_application_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo_inv_application_feed
)
,
data_credit_memo_inv_application_history as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo_inv_application_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo_inv_application_history
)
,
data_credit_memo_line as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo_line' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo_line
)
,
data_credit_memo_line_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo_line_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo_line_feed
)
,
data_credit_memo_line_history as (
    select
        'fivetran_salesforce' as schema_name,
        'credit_memo_line_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.credit_memo_line_history
)
,
data_dashboard_component_localization as (
    select
        'fivetran_salesforce' as schema_name,
        'dashboard_component_localization' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.dashboard_component_localization
)
,
data_dashboard_localization as (
    select
        'fivetran_salesforce' as schema_name,
        'dashboard_localization' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.dashboard_localization
)
,
data_data_assessment_field_metric as (
    select
        'fivetran_salesforce' as schema_name,
        'data_assessment_field_metric' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_assessment_field_metric
)
,
data_data_assessment_metric as (
    select
        'fivetran_salesforce' as schema_name,
        'data_assessment_metric' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_assessment_metric
)
,
data_data_assessment_value_metric as (
    select
        'fivetran_salesforce' as schema_name,
        'data_assessment_value_metric' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_assessment_value_metric
)
,
data_data_content_lens_source as (
    select
        'fivetran_salesforce' as schema_name,
        'data_content_lens_source' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_content_lens_source
)
,
data_data_content_lens_source_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'data_content_lens_source_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_content_lens_source_feed
)
,
data_data_content_lens_source_history as (
    select
        'fivetran_salesforce' as schema_name,
        'data_content_lens_source_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_content_lens_source_history
)
,
data_data_harmonized_model_obj_ref as (
    select
        'fivetran_salesforce' as schema_name,
        'data_harmonized_model_obj_ref' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_harmonized_model_obj_ref
)
,
data_data_knowledge_space as (
    select
        'fivetran_salesforce' as schema_name,
        'data_knowledge_space' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_knowledge_space
)
,
data_data_knowledge_space_session as (
    select
        'fivetran_salesforce' as schema_name,
        'data_knowledge_space_session' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_knowledge_space_session
)
,
data_data_knowledge_src_file_ref as (
    select
        'fivetran_salesforce' as schema_name,
        'data_knowledge_src_file_ref' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_knowledge_src_file_ref
)
,
data_data_obj_secondary_index as (
    select
        'fivetran_salesforce' as schema_name,
        'data_obj_secondary_index' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_obj_secondary_index
)
,
data_data_obj_secondary_index_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'data_obj_secondary_index_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_obj_secondary_index_feed
)
,
data_data_obj_secondary_index_history as (
    select
        'fivetran_salesforce' as schema_name,
        'data_obj_secondary_index_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_obj_secondary_index_history
)
,
data_data_quick_attribute as (
    select
        'fivetran_salesforce' as schema_name,
        'data_quick_attribute' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_quick_attribute
)
,
data_data_quick_attribute_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'data_quick_attribute_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_quick_attribute_feed
)
,
data_data_quick_attribute_history as (
    select
        'fivetran_salesforce' as schema_name,
        'data_quick_attribute_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_quick_attribute_history
)
,
data_data_space as (
    select
        'fivetran_salesforce' as schema_name,
        'data_space' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_space
)
,
data_data_space_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'data_space_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_space_feed
)
,
data_data_space_history as (
    select
        'fivetran_salesforce' as schema_name,
        'data_space_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.data_space_history
)
,
data_digital_wallet as (
    select
        'fivetran_salesforce' as schema_name,
        'digital_wallet' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.digital_wallet
)
,
data_doc_generation_query_result as (
    select
        'fivetran_salesforce' as schema_name,
        'doc_generation_query_result' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.doc_generation_query_result
)
,
data_doc_generation_query_result_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'doc_generation_query_result_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.doc_generation_query_result_feed
)
,
data_doc_generation_query_result_history as (
    select
        'fivetran_salesforce' as schema_name,
        'doc_generation_query_result_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.doc_generation_query_result_history
)
,
data_document_generation_process as (
    select
        'fivetran_salesforce' as schema_name,
        'document_generation_process' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.document_generation_process
)
,
data_engagement_signal as (
    select
        'fivetran_salesforce' as schema_name,
        'engagement_signal' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.engagement_signal
)
,
data_engagement_signal_cmpnd_metric as (
    select
        'fivetran_salesforce' as schema_name,
        'engagement_signal_cmpnd_metric' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.engagement_signal_cmpnd_metric
)
,
data_engagement_signal_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'engagement_signal_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.engagement_signal_feed
)
,
data_engagement_signal_history as (
    select
        'fivetran_salesforce' as schema_name,
        'engagement_signal_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.engagement_signal_history
)
,
data_engagement_signal_metric as (
    select
        'fivetran_salesforce' as schema_name,
        'engagement_signal_metric' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.engagement_signal_metric
)
,
data_entity_particle as (
    select
        'fivetran_salesforce' as schema_name,
        'entity_particle' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_salesforce.entity_particle
)
,
data_epic_c as (
    select
        'fivetran_salesforce' as schema_name,
        'epic_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.epic_c
)
,
data_epic_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'epic_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.epic_feed
)
,
data_epic_history as (
    select
        'fivetran_salesforce' as schema_name,
        'epic_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.epic_history
)
,
data_fivetran_api_call as (
    select
        'fivetran_salesforce' as schema_name,
        'fivetran_api_call' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_salesforce.fivetran_api_call
)
,
data_fivetran_dependent_picklist_relation as (
    select
        'fivetran_salesforce' as schema_name,
        'fivetran_dependent_picklist_relation' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_salesforce.fivetran_dependent_picklist_relation
)
,
data_fivetran_formula as (
    select
        'fivetran_salesforce' as schema_name,
        'fivetran_formula' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_salesforce.fivetran_formula
)
,
data_fivetran_formula_failure_reason as (
    select
        'fivetran_salesforce' as schema_name,
        'fivetran_formula_failure_reason' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_salesforce.fivetran_formula_failure_reason
)
,
data_fivetran_formula_model as (
    select
        'fivetran_salesforce' as schema_name,
        'fivetran_formula_model' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_salesforce.fivetran_formula_model
)
,
data_fivetran_picklist_field as (
    select
        'fivetran_salesforce' as schema_name,
        'fivetran_picklist_field' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_salesforce.fivetran_picklist_field
)
,
data_fivetran_picklist_field_value as (
    select
        'fivetran_salesforce' as schema_name,
        'fivetran_picklist_field_value' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_salesforce.fivetran_picklist_field_value
)
,
data_fivetran_query as (
    select
        'fivetran_salesforce' as schema_name,
        'fivetran_query' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_salesforce.fivetran_query
)
,
data_fivetran_rollup_summary as (
    select
        'fivetran_salesforce' as schema_name,
        'fivetran_rollup_summary' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_salesforce.fivetran_rollup_summary
)
,
data_fivetran_rollup_summary_filter as (
    select
        'fivetran_salesforce' as schema_name,
        'fivetran_rollup_summary_filter' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_salesforce.fivetran_rollup_summary_filter
)
,
data_flow_personal_configuration_c as (
    select
        'fivetran_salesforce' as schema_name,
        'flow_personal_configuration_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.flow_personal_configuration_c
)
,
data_flow_table_view_definition_c as (
    select
        'fivetran_salesforce' as schema_name,
        'flow_table_view_definition_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.flow_table_view_definition_c
)
,
data_forecasting_submission as (
    select
        'fivetran_salesforce' as schema_name,
        'forecasting_submission' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.forecasting_submission
)
,
data_forecasting_submission_item as (
    select
        'fivetran_salesforce' as schema_name,
        'forecasting_submission_item' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.forecasting_submission_item
)
,
data_goal_assignment as (
    select
        'fivetran_salesforce' as schema_name,
        'goal_assignment' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.goal_assignment
)
,
data_goal_assignment_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'goal_assignment_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.goal_assignment_feed
)
,
data_goal_assignment_history as (
    select
        'fivetran_salesforce' as schema_name,
        'goal_assignment_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.goal_assignment_history
)
,
data_goal_assignment_recommendation as (
    select
        'fivetran_salesforce' as schema_name,
        'goal_assignment_recommendation' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.goal_assignment_recommendation
)
,
data_goal_definition as (
    select
        'fivetran_salesforce' as schema_name,
        'goal_definition' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.goal_definition
)
,
data_goal_definition_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'goal_definition_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.goal_definition_feed
)
,
data_goal_definition_history as (
    select
        'fivetran_salesforce' as schema_name,
        'goal_definition_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.goal_definition_history
)
,
data_incp_incident_lv_fields_c as (
    select
        'fivetran_salesforce' as schema_name,
        'incp_incident_lv_fields_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.incp_incident_lv_fields_c
)
,
data_incp_time_zone_selection_c as (
    select
        'fivetran_salesforce' as schema_name,
        'incp_time_zone_selection_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.incp_time_zone_selection_c
)
,
data_invoice as (
    select
        'fivetran_salesforce' as schema_name,
        'invoice' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.invoice
)
,
data_invoice_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'invoice_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.invoice_feed
)
,
data_invoice_history as (
    select
        'fivetran_salesforce' as schema_name,
        'invoice_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.invoice_history
)
,
data_invoice_line as (
    select
        'fivetran_salesforce' as schema_name,
        'invoice_line' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.invoice_line
)
,
data_invoice_line_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'invoice_line_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.invoice_line_feed
)
,
data_invoice_line_history as (
    select
        'fivetran_salesforce' as schema_name,
        'invoice_line_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.invoice_line_history
)
,
data_lcom_account_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_account_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_account_c
)
,
data_lcom_account_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_account_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_account_feed
)
,
data_lcom_license_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_license_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_license_c
)
,
data_lcom_license_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_license_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_license_feed
)
,
data_lcom_license_site_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_license_site_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_license_site_c
)
,
data_lcom_license_site_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_license_site_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_license_site_feed
)
,
data_lcom_member_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_member_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_member_c
)
,
data_lcom_member_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_member_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_member_feed
)
,
data_lcom_opportunity_site_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_opportunity_site_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_opportunity_site_c
)
,
data_lcom_opportunity_term_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_opportunity_term_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_opportunity_term_c
)
,
data_lcom_opportunity_term_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_opportunity_term_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_opportunity_term_feed
)
,
data_lcom_opportunity_term_history as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_opportunity_term_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_opportunity_term_history
)
,
data_lcom_order_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_order_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_order_c
)
,
data_lcom_order_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_order_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_order_feed
)
,
data_lcom_order_line_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_order_line_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_order_line_c
)
,
data_lcom_order_line_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_order_line_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_order_line_feed
)
,
data_lcom_order_modification_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_order_modification_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_order_modification_c
)
,
data_lcom_order_modification_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_order_modification_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_order_modification_feed
)
,
data_lcom_organization_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_organization_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_organization_c
)
,
data_lcom_organization_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_organization_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_organization_feed
)
,
data_lcom_suite_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_suite_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_suite_c
)
,
data_lcom_suite_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_suite_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_suite_feed
)
,
data_lcom_term_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_term_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_term_c
)
,
data_lcom_term_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'lcom_term_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lcom_term_feed
)
,
data_lead as (
    select
        'fivetran_salesforce' as schema_name,
        'lead' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lead
)
,
data_lead_status_c as (
    select
        'fivetran_salesforce' as schema_name,
        'lead_status_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.lead_status_c
)
,
data_learning_com_c as (
    select
        'fivetran_salesforce' as schema_name,
        'learning_com_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.learning_com_c
)
,
data_learning_com_district_license_c as (
    select
        'fivetran_salesforce' as schema_name,
        'learning_com_district_license_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.learning_com_district_license_c
)
,
data_learning_com_district_license_history as (
    select
        'fivetran_salesforce' as schema_name,
        'learning_com_district_license_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.learning_com_district_license_history
)
,
data_learning_com_order_c as (
    select
        'fivetran_salesforce' as schema_name,
        'learning_com_order_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.learning_com_order_c
)
,
data_learning_com_school_license_c as (
    select
        'fivetran_salesforce' as schema_name,
        'learning_com_school_license_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.learning_com_school_license_c
)
,
data_learning_com_school_license_history as (
    select
        'fivetran_salesforce' as schema_name,
        'learning_com_school_license_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.learning_com_school_license_history
)
,
data_market_segment as (
    select
        'fivetran_salesforce' as schema_name,
        'market_segment' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.market_segment
)
,
data_market_segment_activation as (
    select
        'fivetran_salesforce' as schema_name,
        'market_segment_activation' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.market_segment_activation
)
,
data_market_segment_activation_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'market_segment_activation_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.market_segment_activation_feed
)
,
data_market_segment_activation_history as (
    select
        'fivetran_salesforce' as schema_name,
        'market_segment_activation_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.market_segment_activation_history
)
,
data_market_segment_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'market_segment_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.market_segment_feed
)
,
data_market_segment_history as (
    select
        'fivetran_salesforce' as schema_name,
        'market_segment_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.market_segment_history
)
,
data_mkt_sgmnt_actvtn_aud_attribute as (
    select
        'fivetran_salesforce' as schema_name,
        'mkt_sgmnt_actvtn_aud_attribute' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mkt_sgmnt_actvtn_aud_attribute
)
,
data_mkt_sgmnt_actvtn_contact_point as (
    select
        'fivetran_salesforce' as schema_name,
        'mkt_sgmnt_actvtn_contact_point' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mkt_sgmnt_actvtn_contact_point
)
,
data_mkt_sgmt_actv_contact_pt_field as (
    select
        'fivetran_salesforce' as schema_name,
        'mkt_sgmt_actv_contact_pt_field' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mkt_sgmt_actv_contact_pt_field
)
,
data_mkt_sgmt_actv_contact_pt_src as (
    select
        'fivetran_salesforce' as schema_name,
        'mkt_sgmt_actv_contact_pt_src' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mkt_sgmt_actv_contact_pt_src
)
,
data_mkt_sgmt_actv_data_model_fld as (
    select
        'fivetran_salesforce' as schema_name,
        'mkt_sgmt_actv_data_model_fld' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mkt_sgmt_actv_data_model_fld
)
,
data_mkt_sgmt_actv_data_source as (
    select
        'fivetran_salesforce' as schema_name,
        'mkt_sgmt_actv_data_source' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mkt_sgmt_actv_data_source
)
,
data_ml_intent_utterance_suggestion as (
    select
        'fivetran_salesforce' as schema_name,
        'ml_intent_utterance_suggestion' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.ml_intent_utterance_suggestion
)
,
data_mlmodel as (
    select
        'fivetran_salesforce' as schema_name,
        'mlmodel' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mlmodel
)
,
data_mlmodel_factor as (
    select
        'fivetran_salesforce' as schema_name,
        'mlmodel_factor' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mlmodel_factor
)
,
data_mlmodel_factor_component as (
    select
        'fivetran_salesforce' as schema_name,
        'mlmodel_factor_component' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mlmodel_factor_component
)
,
data_mlmodel_metric as (
    select
        'fivetran_salesforce' as schema_name,
        'mlmodel_metric' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.mlmodel_metric
)
,
data_nps_survey_responses_c as (
    select
        'fivetran_salesforce' as schema_name,
        'nps_survey_responses_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.nps_survey_responses_c
)
,
data_object_from_email_accepted_fields_c as (
    select
        'fivetran_salesforce' as schema_name,
        'object_from_email_accepted_fields_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.object_from_email_accepted_fields_c
)
,
data_object_from_email_default_fields_c as (
    select
        'fivetran_salesforce' as schema_name,
        'object_from_email_default_fields_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.object_from_email_default_fields_c
)
,
data_object_milestone_pause_time as (
    select
        'fivetran_salesforce' as schema_name,
        'object_milestone_pause_time' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.object_milestone_pause_time
)
,
data_omni_component_error_log as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_component_error_log' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_component_error_log
)
,
data_omni_component_error_log_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_component_error_log_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_component_error_log_feed
)
,
data_omni_data_pack as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_data_pack' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_data_pack
)
,
data_omni_data_pack_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_data_pack_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_data_pack_feed
)
,
data_omni_data_transform as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_data_transform' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_data_transform
)
,
data_omni_data_transform_item as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_data_transform_item' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_data_transform_item
)
,
data_omni_esignature_template as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_esignature_template' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_esignature_template
)
,
data_omni_global_auto_number as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_global_auto_number' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_global_auto_number
)
,
data_omni_global_auto_number_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_global_auto_number_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_global_auto_number_feed
)
,
data_omni_process as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_process' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_process
)
,
data_omni_process_compilation as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_process_compilation' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_process_compilation
)
,
data_omni_process_element as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_process_element' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_process_element
)
,
data_omni_process_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_process_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_process_feed
)
,
data_omni_process_transient_data as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_process_transient_data' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_process_transient_data
)
,
data_omni_process_transient_data_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_process_transient_data_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_process_transient_data_feed
)
,
data_omni_script_saved_session as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_script_saved_session' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_script_saved_session
)
,
data_omni_script_saved_session_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_script_saved_session_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_script_saved_session_feed
)
,
data_omni_ui_card as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_ui_card' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_ui_card
)
,
data_omni_ui_card_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'omni_ui_card_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.omni_ui_card_feed
)
,
data_operating_hours as (
    select
        'fivetran_salesforce' as schema_name,
        'operating_hours' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.operating_hours
)
,
data_operating_hours_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'operating_hours_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.operating_hours_feed
)
,
data_operating_hours_history as (
    select
        'fivetran_salesforce' as schema_name,
        'operating_hours_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.operating_hours_history
)
,
data_operating_hours_holiday as (
    select
        'fivetran_salesforce' as schema_name,
        'operating_hours_holiday' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.operating_hours_holiday
)
,
data_operating_hours_holiday_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'operating_hours_holiday_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.operating_hours_holiday_feed
)
,
data_operating_hours_holiday_history as (
    select
        'fivetran_salesforce' as schema_name,
        'operating_hours_holiday_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.operating_hours_holiday_history
)
,
data_opportunity as (
    select
        'fivetran_salesforce' as schema_name,
        'opportunity' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.opportunity
)
,
data_opportunity_line_item as (
    select
        'fivetran_salesforce' as schema_name,
        'opportunity_line_item' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.opportunity_line_item
)
,
data_order as (
    select
        'fivetran_salesforce' as schema_name,
        'order' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.order
)
,
data_order_detail_confirmation_c as (
    select
        'fivetran_salesforce' as schema_name,
        'order_detail_confirmation_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.order_detail_confirmation_c
)
,
data_order_detail_confirmation_history as (
    select
        'fivetran_salesforce' as schema_name,
        'order_detail_confirmation_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.order_detail_confirmation_history
)
,
data_order_item as (
    select
        'fivetran_salesforce' as schema_name,
        'order_item' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.order_item
)
,
data_organization as (
    select
        'fivetran_salesforce' as schema_name,
        'organization' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.organization
)
,
data_payment as (
    select
        'fivetran_salesforce' as schema_name,
        'payment' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.payment
)
,
data_payment_auth_adjustment as (
    select
        'fivetran_salesforce' as schema_name,
        'payment_auth_adjustment' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.payment_auth_adjustment
)
,
data_payment_authorization as (
    select
        'fivetran_salesforce' as schema_name,
        'payment_authorization' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.payment_authorization
)
,
data_payment_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'payment_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.payment_feed
)
,
data_payment_gateway as (
    select
        'fivetran_salesforce' as schema_name,
        'payment_gateway' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.payment_gateway
)
,
data_payment_gateway_log as (
    select
        'fivetran_salesforce' as schema_name,
        'payment_gateway_log' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.payment_gateway_log
)
,
data_payment_group as (
    select
        'fivetran_salesforce' as schema_name,
        'payment_group' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.payment_group
)
,
data_payment_line_invoice as (
    select
        'fivetran_salesforce' as schema_name,
        'payment_line_invoice' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.payment_line_invoice
)
,
data_personalization_schema as (
    select
        'fivetran_salesforce' as schema_name,
        'personalization_schema' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.personalization_schema
)
,
data_pricebook_2 as (
    select
        'fivetran_salesforce' as schema_name,
        'pricebook_2' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.pricebook_2
)
,
data_pricebook_entry as (
    select
        'fivetran_salesforce' as schema_name,
        'pricebook_entry' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.pricebook_entry
)
,
data_product_2 as (
    select
        'fivetran_salesforce' as schema_name,
        'product_2' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_2
)
,
data_product_catalog as (
    select
        'fivetran_salesforce' as schema_name,
        'product_catalog' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_catalog
)
,
data_product_catalog_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'product_catalog_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_catalog_feed
)
,
data_product_catalog_history as (
    select
        'fivetran_salesforce' as schema_name,
        'product_catalog_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_catalog_history
)
,
data_product_category as (
    select
        'fivetran_salesforce' as schema_name,
        'product_category' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_category
)
,
data_product_category_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'product_category_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_category_feed
)
,
data_product_category_history as (
    select
        'fivetran_salesforce' as schema_name,
        'product_category_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_category_history
)
,
data_product_category_product as (
    select
        'fivetran_salesforce' as schema_name,
        'product_category_product' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_category_product
)
,
data_product_category_product_history as (
    select
        'fivetran_salesforce' as schema_name,
        'product_category_product_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_category_product_history
)
,
data_product_component_group as (
    select
        'fivetran_salesforce' as schema_name,
        'product_component_group' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_component_group
)
,
data_product_component_group_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'product_component_group_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_component_group_feed
)
,
data_product_component_group_history as (
    select
        'fivetran_salesforce' as schema_name,
        'product_component_group_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_component_group_history
)
,
data_product_config_flow_assignment as (
    select
        'fivetran_salesforce' as schema_name,
        'product_config_flow_assignment' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_config_flow_assignment
)
,
data_product_configuration_flow as (
    select
        'fivetran_salesforce' as schema_name,
        'product_configuration_flow' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_configuration_flow
)
,
data_product_configuration_flow_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'product_configuration_flow_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_configuration_flow_feed
)
,
data_product_configuration_flow_history as (
    select
        'fivetran_salesforce' as schema_name,
        'product_configuration_flow_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_configuration_flow_history
)
,
data_product_related_component as (
    select
        'fivetran_salesforce' as schema_name,
        'product_related_component' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_related_component
)
,
data_product_relationship_type as (
    select
        'fivetran_salesforce' as schema_name,
        'product_relationship_type' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_relationship_type
)
,
data_product_selling_model as (
    select
        'fivetran_salesforce' as schema_name,
        'product_selling_model' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_selling_model
)
,
data_product_selling_model_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'product_selling_model_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_selling_model_feed
)
,
data_product_selling_model_history as (
    select
        'fivetran_salesforce' as schema_name,
        'product_selling_model_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_selling_model_history
)
,
data_product_selling_model_option as (
    select
        'fivetran_salesforce' as schema_name,
        'product_selling_model_option' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.product_selling_model_option
)
,
data_profile as (
    select
        'fivetran_salesforce' as schema_name,
        'profile' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.profile
)
,
data_prompt_action as (
    select
        'fivetran_salesforce' as schema_name,
        'prompt_action' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.prompt_action
)
,
data_prompt_error as (
    select
        'fivetran_salesforce' as schema_name,
        'prompt_error' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.prompt_error
)
,
data_proration_policy as (
    select
        'fivetran_salesforce' as schema_name,
        'proration_policy' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.proration_policy
)
,
data_rcsfl_admin_setting_c as (
    select
        'fivetran_salesforce' as schema_name,
        'rcsfl_admin_setting_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.rcsfl_admin_setting_c
)
,
data_rcsfl_ai_notes_c as (
    select
        'fivetran_salesforce' as schema_name,
        'rcsfl_ai_notes_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.rcsfl_ai_notes_c
)
,
data_rcsfl_ring_central_webinar_token_c as (
    select
        'fivetran_salesforce' as schema_name,
        'rcsfl_ring_central_webinar_token_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.rcsfl_ring_central_webinar_token_c
)
,
data_record_type as (
    select
        'fivetran_salesforce' as schema_name,
        'record_type' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.record_type
)
,
data_refund as (
    select
        'fivetran_salesforce' as schema_name,
        'refund' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.refund
)
,
data_refund_line_payment as (
    select
        'fivetran_salesforce' as schema_name,
        'refund_line_payment' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.refund_line_payment
)
,
data_revenue_async_operation as (
    select
        'fivetran_salesforce' as schema_name,
        'revenue_async_operation' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.revenue_async_operation
)
,
data_revenue_transaction_error_log as (
    select
        'fivetran_salesforce' as schema_name,
        'revenue_transaction_error_log' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.revenue_transaction_error_log
)
,
data_sbqq_field_metadata_c as (
    select
        'fivetran_salesforce' as schema_name,
        'sbqq_field_metadata_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sbqq_field_metadata_c
)
,
data_sbqq_product_option_c as (
    select
        'fivetran_salesforce' as schema_name,
        'sbqq_product_option_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sbqq_product_option_c
)
,
data_sbqq_quote_c as (
    select
        'fivetran_salesforce' as schema_name,
        'sbqq_quote_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sbqq_quote_c
)
,
data_sbqq_quote_line_c as (
    select
        'fivetran_salesforce' as schema_name,
        'sbqq_quote_line_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sbqq_quote_line_c
)
,
data_sbqq_quote_line_group_c as (
    select
        'fivetran_salesforce' as schema_name,
        'sbqq_quote_line_group_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sbqq_quote_line_group_c
)
,
data_sender_email_address as (
    select
        'fivetran_salesforce' as schema_name,
        'sender_email_address' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sender_email_address
)
,
data_service_and_training_request_c as (
    select
        'fivetran_salesforce' as schema_name,
        'service_and_training_request_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.service_and_training_request_c
)
,
data_service_and_training_request_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'service_and_training_request_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.service_and_training_request_feed
)
,
data_service_and_training_request_history as (
    select
        'fivetran_salesforce' as schema_name,
        'service_and_training_request_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.service_and_training_request_history
)
,
data_setup_assistant_step as (
    select
        'fivetran_salesforce' as schema_name,
        'setup_assistant_step' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.setup_assistant_step
)
,
data_sfdc_partner_sbscr_offer as (
    select
        'fivetran_salesforce' as schema_name,
        'sfdc_partner_sbscr_offer' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sfdc_partner_sbscr_offer
)
,
data_sfdc_partner_sbscr_offer_history as (
    select
        'fivetran_salesforce' as schema_name,
        'sfdc_partner_sbscr_offer_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sfdc_partner_sbscr_offer_history
)
,
data_sfdc_partner_sbscr_offer_item as (
    select
        'fivetran_salesforce' as schema_name,
        'sfdc_partner_sbscr_offer_item' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.sfdc_partner_sbscr_offer_item
)
,
data_slack_channel_related_record as (
    select
        'fivetran_salesforce' as schema_name,
        'slack_channel_related_record' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.slack_channel_related_record
)
,
data_state_profile_c as (
    select
        'fivetran_salesforce' as schema_name,
        'state_profile_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.state_profile_c
)
,
data_switches_c as (
    select
        'fivetran_salesforce' as schema_name,
        'switches_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.switches_c
)
,
data_team_c as (
    select
        'fivetran_salesforce' as schema_name,
        'team_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.team_c
)
,
data_team_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'team_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.team_feed
)
,
data_team_history as (
    select
        'fivetran_salesforce' as schema_name,
        'team_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.team_history
)
,
data_team_member_c as (
    select
        'fivetran_salesforce' as schema_name,
        'team_member_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.team_member_c
)
,
data_team_member_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'team_member_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.team_member_feed
)
,
data_team_member_history as (
    select
        'fivetran_salesforce' as schema_name,
        'team_member_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.team_member_history
)
,
data_time_slot as (
    select
        'fivetran_salesforce' as schema_name,
        'time_slot' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.time_slot
)
,
data_time_slot_history as (
    select
        'fivetran_salesforce' as schema_name,
        'time_slot_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.time_slot_history
)
,
data_training_session_c as (
    select
        'fivetran_salesforce' as schema_name,
        'training_session_c' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.training_session_c
)
,
data_training_session_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'training_session_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.training_session_feed
)
,
data_unit_of_measure as (
    select
        'fivetran_salesforce' as schema_name,
        'unit_of_measure' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.unit_of_measure
)
,
data_unstructured_storage_space as (
    select
        'fivetran_salesforce' as schema_name,
        'unstructured_storage_space' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.unstructured_storage_space
)
,
data_user as (
    select
        'fivetran_salesforce' as schema_name,
        'user' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.user
)
,
data_user_history as (
    select
        'fivetran_salesforce' as schema_name,
        'user_history' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.user_history
)
,
data_user_prov_account as (
    select
        'fivetran_salesforce' as schema_name,
        'user_prov_account' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.user_prov_account
)
,
data_user_prov_account_staging as (
    select
        'fivetran_salesforce' as schema_name,
        'user_prov_account_staging' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.user_prov_account_staging
)
,
data_user_prov_mock_target as (
    select
        'fivetran_salesforce' as schema_name,
        'user_prov_mock_target' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.user_prov_mock_target
)
,
data_user_provisioning_log as (
    select
        'fivetran_salesforce' as schema_name,
        'user_provisioning_log' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.user_provisioning_log
)
,
data_user_provisioning_request as (
    select
        'fivetran_salesforce' as schema_name,
        'user_provisioning_request' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.user_provisioning_request
)
,
data_user_role as (
    select
        'fivetran_salesforce' as schema_name,
        'user_role' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        null::date as max_created_date
    from rawdata.fivetran_salesforce.user_role
)
,
data_video_call as (
    select
        'fivetran_salesforce' as schema_name,
        'video_call' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.video_call
)
,
data_video_call_feed as (
    select
        'fivetran_salesforce' as schema_name,
        'video_call_feed' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.video_call_feed
)
,
data_video_call_participant as (
    select
        'fivetran_salesforce' as schema_name,
        'video_call_participant' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.video_call_participant
)
,
data_video_call_recording as (
    select
        'fivetran_salesforce' as schema_name,
        'video_call_recording' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.video_call_recording
)
,
data_voice_call_recording as (
    select
        'fivetran_salesforce' as schema_name,
        'voice_call_recording' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.voice_call_recording
)
,
data_voice_chnl_interaction_event as (
    select
        'fivetran_salesforce' as schema_name,
        'voice_chnl_interaction_event' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.voice_chnl_interaction_event
)
,
data_voice_chnl_intrctn_dtl_event as (
    select
        'fivetran_salesforce' as schema_name,
        'voice_chnl_intrctn_dtl_event' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.voice_chnl_intrctn_dtl_event
)
,
data_web_link as (
    select
        'fivetran_salesforce' as schema_name,
        'web_link' as table_name,
        count(1) as total_rows,
        max(_fivetran_synced)::date as max_fivetran_synced_date,
        max(created_date)::date as max_created_date
    from rawdata.fivetran_salesforce.web_link
)

/*==============================================================================================*/
/*====================================  final queries  =========================================*/
/*==============================================================================================*/
,
used_sources as (
    select 'fivetran_hubspot' as schema_name, 'company' as table_name
    union all
    select 'fivetran_hubspot' as schema_name, 'deal' as table_name
    union all
    select 'fivetran_hubspot' as schema_name, 'deal_company' as table_name
    union all
    select 'fivetran_salesforce' as schema_name, 'account' as table_name
    union all
    select 'fivetran_salesforce' as schema_name, 'campaign' as table_name
    union all
    select 'fivetran_salesforce' as schema_name, 'case' as table_name
    union all
    select 'fivetran_salesforce' as schema_name, 'contact' as table_name
    union all
    select 'fivetran_salesforce' as schema_name, 'contact_history' as table_name
    union all
    select 'fivetran_salesforce' as schema_name, 'lcom_organization_c' as table_name
    union all
    select 'fivetran_salesforce' as schema_name, 'lcom_suite_c' as table_name
    union all
    select 'fivetran_salesforce' as schema_name, 'opportunity' as table_name
    union all
    select 'fivetran_salesforce' as schema_name, 'opportunity_line_item' as table_name
    union all
    select 'fivetran_salesforce' as schema_name, 'product_2' as table_name
    union all
    select 'fivetran_salesforce' as schema_name, 'record_type' as table_name
    union all
    select 'fivetran_salesforce' as schema_name, 'sbqq_quote_c' as table_name
    union all
    select 'fivetran_salesforce' as schema_name, 'training_session_c' as table_name
    union all
    select 'fivetran_salesforce' as schema_name, 'user' as table_name
)
,
fivetran_sources_report as (
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.association_type f
join data_association_type d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.property_createdate::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_hubspot.company f
join data_company d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.company_company f
join data_company_company d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.property_createdate::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_hubspot.contact f
join data_contact_hubspot d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.contact_company f
join data_contact_company d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.property_hs_createdate::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_hubspot.deal f
join data_deal d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.deal_company f
join data_deal_company d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.deal_contact f
join data_deal_contact d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.deal_pipeline f
join data_deal_pipeline d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.deal_pipeline_stage f
join data_deal_pipeline_stage d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.deal_stage f
join data_deal_stage d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.property_hs_createdate::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_hubspot.invoice f
join data_invoice_hubspot d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.invoice_company f
join data_invoice_company d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.invoice_contact f
join data_invoice_contact d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.invoice_deal f
join data_invoice_deal d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.invoice_line_item f
join data_invoice_line_item d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.property_createdate::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_hubspot.line_item f
join data_line_item d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.line_item_deal f
join data_line_item_deal d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.property_hs_createdate::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_hubspot.payment f
join data_payment_hubspot d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.payment_company f
join data_payment_company d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.payment_contact f
join data_payment_contact d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.payment_deal f
join data_payment_deal d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.payment_invoice f
join data_payment_invoice d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_hubspot.payment_line_item f
join data_payment_line_item d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.property_createdate::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_hubspot.product f
join data_product d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.abn_experiment f
join data_abn_experiment d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.abn_experiment_cohort f
join data_abn_experiment_cohort d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.abn_experiment_cohort_attr_val f
join data_abn_experiment_cohort_attr_val d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.abn_experiment_engmt_sgnl_mtrc f
join data_abn_experiment_engmt_sgnl_mtrc d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.account f
join data_account d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.account_brand f
join data_account_brand d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.account_relation_c f
join data_account_relation_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.account_relation_history f
join data_account_relation_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_target f
join data_activation_target d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_target_feed f
join data_activation_target_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_target_history f
join data_activation_target_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_target_platform f
join data_activation_target_platform d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_target_platform_history f
join data_activation_target_platform_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_target_secure_ftp f
join data_activation_target_secure_ftp d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_trgt_int_org_access f
join data_activation_trgt_int_org_access d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_trgt_int_org_access_feed f
join data_activation_trgt_int_org_access_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activation_trgt_int_org_access_history f
join data_activation_trgt_int_org_access_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activity_roll_up_c f
join data_activity_roll_up_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.activity_roll_up_history f
join data_activity_roll_up_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.actv_tgt_platform_field_value f
join data_actv_tgt_platform_field_value d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.actv_tgt_platform_field_value_history f
join data_actv_tgt_platform_field_value_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.agileed_connect_link_data_problem_report_c f
join data_agileed_connect_link_data_problem_report_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.agileed_fieldmapping_c f
join data_agileed_fieldmapping_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.ai_job_run f
join data_ai_job_run d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.alternative_payment_method f
join data_alternative_payment_method d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.analytics_user_attr_func_tkn f
join data_analytics_user_attr_func_tkn d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.apex_code_coverage_aggregate f
join data_apex_code_coverage_aggregate d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.app_usage_assignment f
join data_app_usage_assignment d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.async_operation_tracker f
join data_async_operation_tracker d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_definition f
join data_attribute_definition d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_definition_feed f
join data_attribute_definition_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_definition_history f
join data_attribute_definition_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_picklist f
join data_attribute_picklist d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_picklist_feed f
join data_attribute_picklist_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_picklist_history f
join data_attribute_picklist_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_picklist_value f
join data_attribute_picklist_value d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_picklist_value_feed f
join data_attribute_picklist_value_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.attribute_picklist_value_history f
join data_attribute_picklist_value_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.automation_analytic_c f
join data_automation_analytic_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.business_operations_request_c f
join data_business_operations_request_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.business_operations_request_feed f
join data_business_operations_request_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.business_operations_request_history f
join data_business_operations_request_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.business_ops_request_c f
join data_business_ops_request_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.calc_affinity_engmt_sgnl f
join data_calc_affinity_engmt_sgnl d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.calculated_affinity f
join data_calculated_affinity d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.calculated_affinity_field f
join data_calculated_affinity_field d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.calculated_insight_range_bound f
join data_calculated_insight_range_bound d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.campaign f
join data_campaign d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.card_payment_method f
join data_card_payment_method d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.case f
join data_case d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.case_comment f
join data_case_comment d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.case_rel_harmonized_content f
join data_case_rel_harmonized_content d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.case_related_issue f
join data_case_related_issue d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.case_solution f
join data_case_solution d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.chat_report_cr_bot_c f
join data_chat_report_cr_bot_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.chat_report_cr_custom_label_c f
join data_chat_report_cr_custom_label_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.chat_report_cr_flow_data_c f
join data_chat_report_cr_flow_data_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.chat_report_cr_report_type_c f
join data_chat_report_cr_report_type_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.chat_report_cr_skill_based_routing_rule_c f
join data_chat_report_cr_skill_based_routing_rule_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.codesters_codesters_license_c f
join data_codesters_codesters_license_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.codesters_codesters_member_c f
join data_codesters_codesters_member_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.codesters_codesters_organization_c f
join data_codesters_codesters_organization_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.codesters_codesters_settings_c f
join data_codesters_codesters_settings_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.codesters_opportunity_license_c f
join data_codesters_opportunity_license_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.contact f
join data_contact d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.contact_center_bulk_op f
join data_contact_center_bulk_op d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.contact_history f
join data_contact_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.contract f
join data_contract d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.conversation_api_log f
join data_conversation_api_log d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.conversation_api_log_obj_sum f
join data_conversation_api_log_obj_sum d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo f
join data_credit_memo d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo_feed f
join data_credit_memo_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo_history f
join data_credit_memo_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo_inv_application f
join data_credit_memo_inv_application d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo_inv_application_feed f
join data_credit_memo_inv_application_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo_inv_application_history f
join data_credit_memo_inv_application_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo_line f
join data_credit_memo_line d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo_line_feed f
join data_credit_memo_line_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.credit_memo_line_history f
join data_credit_memo_line_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.dashboard_component_localization f
join data_dashboard_component_localization d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.dashboard_localization f
join data_dashboard_localization d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_assessment_field_metric f
join data_data_assessment_field_metric d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_assessment_metric f
join data_data_assessment_metric d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_assessment_value_metric f
join data_data_assessment_value_metric d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_content_lens_source f
join data_data_content_lens_source d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_content_lens_source_feed f
join data_data_content_lens_source_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_content_lens_source_history f
join data_data_content_lens_source_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_harmonized_model_obj_ref f
join data_data_harmonized_model_obj_ref d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_knowledge_space f
join data_data_knowledge_space d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_knowledge_space_session f
join data_data_knowledge_space_session d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_knowledge_src_file_ref f
join data_data_knowledge_src_file_ref d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_obj_secondary_index f
join data_data_obj_secondary_index d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_obj_secondary_index_feed f
join data_data_obj_secondary_index_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_obj_secondary_index_history f
join data_data_obj_secondary_index_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_quick_attribute f
join data_data_quick_attribute d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_quick_attribute_feed f
join data_data_quick_attribute_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_quick_attribute_history f
join data_data_quick_attribute_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_space f
join data_data_space d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_space_feed f
join data_data_space_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.data_space_history f
join data_data_space_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.digital_wallet f
join data_digital_wallet d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.doc_generation_query_result f
join data_doc_generation_query_result d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.doc_generation_query_result_feed f
join data_doc_generation_query_result_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.doc_generation_query_result_history f
join data_doc_generation_query_result_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.document_generation_process f
join data_document_generation_process d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.engagement_signal f
join data_engagement_signal d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.engagement_signal_cmpnd_metric f
join data_engagement_signal_cmpnd_metric d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.engagement_signal_feed f
join data_engagement_signal_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.engagement_signal_history f
join data_engagement_signal_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.engagement_signal_metric f
join data_engagement_signal_metric d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_salesforce.entity_particle f
join data_entity_particle d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.epic_c f
join data_epic_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.epic_feed f
join data_epic_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.epic_history f
join data_epic_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_salesforce.fivetran_api_call f
join data_fivetran_api_call d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_salesforce.fivetran_dependent_picklist_relation f
join data_fivetran_dependent_picklist_relation d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_salesforce.fivetran_formula f
join data_fivetran_formula d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_salesforce.fivetran_formula_failure_reason f
join data_fivetran_formula_failure_reason d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_salesforce.fivetran_formula_model f
join data_fivetran_formula_model d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_salesforce.fivetran_picklist_field f
join data_fivetran_picklist_field d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_salesforce.fivetran_picklist_field_value f
join data_fivetran_picklist_field_value d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_salesforce.fivetran_query f
join data_fivetran_query d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_salesforce.fivetran_rollup_summary f
join data_fivetran_rollup_summary d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_salesforce.fivetran_rollup_summary_filter f
join data_fivetran_rollup_summary_filter d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.flow_personal_configuration_c f
join data_flow_personal_configuration_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.flow_table_view_definition_c f
join data_flow_table_view_definition_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.forecasting_submission f
join data_forecasting_submission d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.forecasting_submission_item f
join data_forecasting_submission_item d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.goal_assignment f
join data_goal_assignment d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.goal_assignment_feed f
join data_goal_assignment_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.goal_assignment_history f
join data_goal_assignment_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.goal_assignment_recommendation f
join data_goal_assignment_recommendation d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.goal_definition f
join data_goal_definition d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.goal_definition_feed f
join data_goal_definition_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.goal_definition_history f
join data_goal_definition_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.incp_incident_lv_fields_c f
join data_incp_incident_lv_fields_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.incp_time_zone_selection_c f
join data_incp_time_zone_selection_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.invoice f
join data_invoice d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.invoice_feed f
join data_invoice_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.invoice_history f
join data_invoice_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.invoice_line f
join data_invoice_line d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.invoice_line_feed f
join data_invoice_line_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.invoice_line_history f
join data_invoice_line_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_account_c f
join data_lcom_account_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_account_feed f
join data_lcom_account_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_license_c f
join data_lcom_license_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_license_feed f
join data_lcom_license_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_license_site_c f
join data_lcom_license_site_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_license_site_feed f
join data_lcom_license_site_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_member_c f
join data_lcom_member_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_member_feed f
join data_lcom_member_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_opportunity_site_c f
join data_lcom_opportunity_site_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_opportunity_term_c f
join data_lcom_opportunity_term_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_opportunity_term_feed f
join data_lcom_opportunity_term_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_opportunity_term_history f
join data_lcom_opportunity_term_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_order_c f
join data_lcom_order_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_order_feed f
join data_lcom_order_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_order_line_c f
join data_lcom_order_line_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_order_line_feed f
join data_lcom_order_line_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_order_modification_c f
join data_lcom_order_modification_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_order_modification_feed f
join data_lcom_order_modification_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_organization_c f
join data_lcom_organization_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_organization_feed f
join data_lcom_organization_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_suite_c f
join data_lcom_suite_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_suite_feed f
join data_lcom_suite_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_term_c f
join data_lcom_term_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lcom_term_feed f
join data_lcom_term_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lead f
join data_lead d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.lead_status_c f
join data_lead_status_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.learning_com_c f
join data_learning_com_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.learning_com_district_license_c f
join data_learning_com_district_license_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.learning_com_district_license_history f
join data_learning_com_district_license_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.learning_com_order_c f
join data_learning_com_order_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.learning_com_school_license_c f
join data_learning_com_school_license_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.learning_com_school_license_history f
join data_learning_com_school_license_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.market_segment f
join data_market_segment d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.market_segment_activation f
join data_market_segment_activation d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.market_segment_activation_feed f
join data_market_segment_activation_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.market_segment_activation_history f
join data_market_segment_activation_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.market_segment_feed f
join data_market_segment_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.market_segment_history f
join data_market_segment_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mkt_sgmnt_actvtn_aud_attribute f
join data_mkt_sgmnt_actvtn_aud_attribute d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mkt_sgmnt_actvtn_contact_point f
join data_mkt_sgmnt_actvtn_contact_point d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mkt_sgmt_actv_contact_pt_field f
join data_mkt_sgmt_actv_contact_pt_field d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mkt_sgmt_actv_contact_pt_src f
join data_mkt_sgmt_actv_contact_pt_src d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mkt_sgmt_actv_data_model_fld f
join data_mkt_sgmt_actv_data_model_fld d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mkt_sgmt_actv_data_source f
join data_mkt_sgmt_actv_data_source d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.ml_intent_utterance_suggestion f
join data_ml_intent_utterance_suggestion d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mlmodel f
join data_mlmodel d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mlmodel_factor f
join data_mlmodel_factor d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mlmodel_factor_component f
join data_mlmodel_factor_component d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.mlmodel_metric f
join data_mlmodel_metric d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.nps_survey_responses_c f
join data_nps_survey_responses_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.object_from_email_accepted_fields_c f
join data_object_from_email_accepted_fields_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.object_from_email_default_fields_c f
join data_object_from_email_default_fields_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.object_milestone_pause_time f
join data_object_milestone_pause_time d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_component_error_log f
join data_omni_component_error_log d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_component_error_log_feed f
join data_omni_component_error_log_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_data_pack f
join data_omni_data_pack d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_data_pack_feed f
join data_omni_data_pack_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_data_transform f
join data_omni_data_transform d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_data_transform_item f
join data_omni_data_transform_item d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_esignature_template f
join data_omni_esignature_template d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_global_auto_number f
join data_omni_global_auto_number d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_global_auto_number_feed f
join data_omni_global_auto_number_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_process f
join data_omni_process d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_process_compilation f
join data_omni_process_compilation d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_process_element f
join data_omni_process_element d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_process_feed f
join data_omni_process_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_process_transient_data f
join data_omni_process_transient_data d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_process_transient_data_feed f
join data_omni_process_transient_data_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_script_saved_session f
join data_omni_script_saved_session d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_script_saved_session_feed f
join data_omni_script_saved_session_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_ui_card f
join data_omni_ui_card d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.omni_ui_card_feed f
join data_omni_ui_card_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.operating_hours f
join data_operating_hours d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.operating_hours_feed f
join data_operating_hours_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.operating_hours_history f
join data_operating_hours_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.operating_hours_holiday f
join data_operating_hours_holiday d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.operating_hours_holiday_feed f
join data_operating_hours_holiday_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.operating_hours_holiday_history f
join data_operating_hours_holiday_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.opportunity f
join data_opportunity d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.opportunity_line_item f
join data_opportunity_line_item d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.order f
join data_order d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.order_detail_confirmation_c f
join data_order_detail_confirmation_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.order_detail_confirmation_history f
join data_order_detail_confirmation_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.order_item f
join data_order_item d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.organization f
join data_organization d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.payment f
join data_payment d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.payment_auth_adjustment f
join data_payment_auth_adjustment d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.payment_authorization f
join data_payment_authorization d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.payment_feed f
join data_payment_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.payment_gateway f
join data_payment_gateway d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.payment_gateway_log f
join data_payment_gateway_log d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.payment_group f
join data_payment_group d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.payment_line_invoice f
join data_payment_line_invoice d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.personalization_schema f
join data_personalization_schema d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.pricebook_2 f
join data_pricebook_2 d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.pricebook_entry f
join data_pricebook_entry d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_2 f
join data_product_2 d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_catalog f
join data_product_catalog d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_catalog_feed f
join data_product_catalog_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_catalog_history f
join data_product_catalog_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_category f
join data_product_category d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_category_feed f
join data_product_category_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_category_history f
join data_product_category_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_category_product f
join data_product_category_product d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_category_product_history f
join data_product_category_product_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_component_group f
join data_product_component_group d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_component_group_feed f
join data_product_component_group_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_component_group_history f
join data_product_component_group_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_config_flow_assignment f
join data_product_config_flow_assignment d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_configuration_flow f
join data_product_configuration_flow d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_configuration_flow_feed f
join data_product_configuration_flow_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_configuration_flow_history f
join data_product_configuration_flow_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_related_component f
join data_product_related_component d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_relationship_type f
join data_product_relationship_type d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_selling_model f
join data_product_selling_model d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_selling_model_feed f
join data_product_selling_model_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_selling_model_history f
join data_product_selling_model_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.product_selling_model_option f
join data_product_selling_model_option d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.profile f
join data_profile d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.prompt_action f
join data_prompt_action d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.prompt_error f
join data_prompt_error d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.proration_policy f
join data_proration_policy d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.rcsfl_admin_setting_c f
join data_rcsfl_admin_setting_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.rcsfl_ai_notes_c f
join data_rcsfl_ai_notes_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.rcsfl_ring_central_webinar_token_c f
join data_rcsfl_ring_central_webinar_token_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.record_type f
join data_record_type d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.refund f
join data_refund d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.refund_line_payment f
join data_refund_line_payment d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.revenue_async_operation f
join data_revenue_async_operation d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.revenue_transaction_error_log f
join data_revenue_transaction_error_log d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sbqq_field_metadata_c f
join data_sbqq_field_metadata_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sbqq_product_option_c f
join data_sbqq_product_option_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sbqq_quote_c f
join data_sbqq_quote_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sbqq_quote_line_c f
join data_sbqq_quote_line_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sbqq_quote_line_group_c f
join data_sbqq_quote_line_group_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sender_email_address f
join data_sender_email_address d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.service_and_training_request_c f
join data_service_and_training_request_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.service_and_training_request_feed f
join data_service_and_training_request_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.service_and_training_request_history f
join data_service_and_training_request_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.setup_assistant_step f
join data_setup_assistant_step d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sfdc_partner_sbscr_offer f
join data_sfdc_partner_sbscr_offer d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sfdc_partner_sbscr_offer_history f
join data_sfdc_partner_sbscr_offer_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.sfdc_partner_sbscr_offer_item f
join data_sfdc_partner_sbscr_offer_item d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.slack_channel_related_record f
join data_slack_channel_related_record d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.state_profile_c f
join data_state_profile_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.switches_c f
join data_switches_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.team_c f
join data_team_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.team_feed f
join data_team_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.team_history f
join data_team_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.team_member_c f
join data_team_member_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.team_member_feed f
join data_team_member_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.team_member_history f
join data_team_member_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.time_slot f
join data_time_slot d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.time_slot_history f
join data_time_slot_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.training_session_c f
join data_training_session_c d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.training_session_feed f
join data_training_session_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.unit_of_measure f
join data_unit_of_measure d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.unstructured_storage_space f
join data_unstructured_storage_space d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.user f
join data_user d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.user_history f
join data_user_history d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.user_prov_account f
join data_user_prov_account d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.user_prov_account_staging f
join data_user_prov_account_staging d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.user_prov_mock_target f
join data_user_prov_mock_target d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.user_provisioning_log f
join data_user_provisioning_log d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.user_provisioning_request f
join data_user_provisioning_request d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    null::integer as changed_on_max_created_date
from rawdata.fivetran_salesforce.user_role f
join data_user_role d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.video_call f
join data_video_call d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.video_call_feed f
join data_video_call_feed d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.video_call_participant f
join data_video_call_participant d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.video_call_recording f
join data_video_call_recording d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.voice_call_recording f
join data_voice_call_recording d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.voice_chnl_interaction_event f
join data_voice_chnl_interaction_event d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.voice_chnl_intrctn_dtl_event f
join data_voice_chnl_intrctn_dtl_event d
    on 1 = 1
group by all
union all
select
    d.schema_name,
    d.table_name,
    d.total_rows,
    d.max_fivetran_synced_date,
    sum(case when f._fivetran_synced::date = d.max_fivetran_synced_date then 1 else 0 end) as changed_on_max_fivetran_synced_date,
    d.max_created_date,
    sum(case when f.created_date::date = d.max_created_date then 1 else 0 end) as changed_on_max_created_date
from rawdata.fivetran_salesforce.web_link f
join data_web_link d
    on 1 = 1
group by all

)

select
    r.schema_name,
    r.table_name,
    r.total_rows,
    r.max_fivetran_synced_date AT TIME ZONE 'America/Los_Angeles' as max_fivetran_synced_date,
    r.changed_on_max_fivetran_synced_date ,
    r.max_created_date AT TIME ZONE 'America/Los_Angeles' as max_created_date,
    r.changed_on_max_created_date,
    case
        when us.table_name is not null then 'Y'
        else 'N'
    end as used_as_source
from fivetran_sources_report r
left join used_sources us
    on r.schema_name = us.schema_name
    and r.table_name = us.table_name
