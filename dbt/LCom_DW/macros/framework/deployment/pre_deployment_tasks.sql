{% macro pre_deployment_tasks() %}

{% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %}


 {{ log('Starting pre deployment tasks', info=True) }}

 {% set pre_deployment_sql %}

 {% set target_db = (target.database | string) %}

 {% if target_db | upper == 'QA' %}

   create table qa.common.dim_account_history as select * from dw.common.dim_account_history limit 100;

 {% endif %} 
					
update common.dim_account_history
set sfdc_ultimate_parent_current_renewal_arr=0;



update common.dim_account_history
set scd_hash = md5(coalesce(cast(lcom_organization_id as varchar ), '')
         || '|' || coalesce(cast(lcom_trial as varchar ), '')
         || '|' || coalesce(cast(lcom_demo as varchar ), '')
         || '|' || coalesce(cast(lcom_country_name as varchar ), '')
         || '|' || coalesce(cast(lcom_organization_name as varchar ), '')
         || '|' || coalesce(cast(lcom_organization_type as varchar ), '')
         || '|' || coalesce(cast(lcom_parent_organization_name as varchar ), '')
         || '|' || coalesce(cast(lcom_state_province_code as varchar ), '')
         || '|' || coalesce(cast(sfdc_parent_id as varchar ), '')
         || '|' || coalesce(cast(SFDC_record_type as varchar ), '')
         || '|' || coalesce(cast(sfdc_current_renewal_arr as varchar ), '')
         || '|' || coalesce(cast(sfdc_state_initiative as varchar ), '')
         || '|' || coalesce(cast(sfdc_state_initiative_school as varchar ), '')
         || '|' || coalesce(cast(sfdc_state_eligible_or_initiative as varchar ), '')
         || '|' || coalesce(cast(sfdc_state_eligible_or_initiative_school as varchar ), '')
         || '|' || coalesce(cast(sfdc_owner_id as varchar ), '')
         || '|' || coalesce(cast(sfdc_owner_name_text as varchar ), '')
         || '|' || coalesce(cast(sfdc_billing_state as varchar ), '')
         || '|' || coalesce(cast(sfdc_billing_state_code as varchar ), '')
         || '|' || coalesce(cast(sfdc_grade_levels as varchar ), '')
         || '|' || coalesce(cast(sfdc_k_12_enrollment as varchar ), '')
         || '|' || coalesce(cast(sfdc_k_8_enrollment as varchar ), '')
         || '|' || coalesce(cast(sfdc_name as varchar ), '')
         || '|' || coalesce(cast(sfdc_parent_name as varchar ), '')
         || '|' || coalesce(cast(sfdc_ultimate_account_owner as varchar ), '')
         || '|' || coalesce(cast(sfdc_ultimate_parent_account as varchar ), '')
         || '|' || coalesce(cast(sfdc_ultimate_parent_billing_state as varchar ), '')
         || '|' || coalesce(cast(sfdc_ultimate_parent_id as varchar ), '')
         || '|' || coalesce(cast(sfdc_urban_rural as varchar ), '')
         || '|' || coalesce(cast(isHighSchool as varchar ), '')
         || '|' || coalesce(cast(sfdc_ultimate_parent_current_renewal_arr as varchar ), '')
         || '|' || coalesce(cast(sfdc_billing_country as varchar ), '')
         || '|' || coalesce(cast(sfdc_billing_country_code as varchar ), '')
         || '|' || coalesce(cast(sfdc_district_enrollment as varchar ), '')
         || '|' || coalesce(cast(sfdc_school_enrollment as varchar ), '')
         || '|' || coalesce(cast(sfdc_state_program_eligible as varchar ), '')
         || '|' || coalesce(cast(sfdc_county_name as varchar ), '')
         || '|' || coalesce(cast(sfdc_customer_level as varchar ), '')
         || '|' || coalesce(cast(sfdc_customer_level_override as varchar ), '')
         || '|' || coalesce(cast(lcom_parent_organization_id as varchar ), '')
        );

 {% endset %}

    {% if pre_deployment_sql | trim %}
        {% do run_query(pre_deployment_sql) %}
        {{ log('Finished pre deployment tasks', info=True) }}
    {% else %}
        {{ log('No pre deployment tasks to execute', info=True) }}
    {% endif %}


{% endif %}
 
 {% endmacro %}