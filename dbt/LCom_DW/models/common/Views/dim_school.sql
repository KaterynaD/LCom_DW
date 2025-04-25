{{ config(materialized='view',
   bind=False
)
 }}
select 
account_id as school_id,
--LCOM columns
lcom_organization_id as Lcom_school_id,
lcom_organization_name as LCOM_School_Name,
lcom_parent_organization_id as LCOM_District_Id,
lcom_parent_organization_name as LCOM_District_Name,
LCOM_trial,
LCOM_demo,
LCOM_postal_code,
LCOM_state_province_key,
LCOM_state_province_code,
LCOM_state_province_name,
LCOM_country_code,
LCOM_country_name,
LCOM_alpha3_code,
LCOM_numeric_code,
LCOM_external_sis_id,
LCOM_nces_id,
LCOM_created_datetime,
LCOM_modified_datetime,
LCOM_deleted_datetime,
--Salesforce columns only populated for schools
sfdc_account_id as SFDC_school_id,
SFDC_name as SFDC_School_Name,
SFDC_created_date,
SFDC_last_modified_date,
SFDC_computer_os,
SFDC_district_presence,
SFDC_education_climate_index,
SFDC_fiscal_title_i_eligible_school,
SFDC_fiscal_title_i_school,
SFDC_fiscal_title_i_school_yes_no,
SFDC_fiscal_title_i_schoolwide,
SFDC_fiscal_title_i_schoolwide_yes_no,
SFDC_free_reduced_lunch,
SFDC_hi_speed_classroom_internet,
SFDC_hi_speed_internet,
SFDC_k_8_district_presence,
SFDC_migration_tool,
SFDC_parent_churned,
SFDC_parent_id SFDC_District_Id,
SFDC_parent_long_name,
SFDC_parent_mdr,
SFDC_parent_name SFDC_District_Name,
SFDC_parent_name_proper_case,
SFDC_parent_owner_id,
SFDC_parent_uid,
SFDC_school_enrollment,
SFDC_school_id as SFDC_school_id_nces,
SFDC_school_type,
SFDC_teachers_in_building,
SFDC_ultimate_account_lifecycle_stage,
SFDC_ultimate_parent_account,
SFDC_ultimate_parent_billing_state,
SFDC_ultimate_parent_id,
SFDC_ultimate_parent_total_renewal_arr_2,
SFDC_virtual_school,
SFDC_virtual_status_text,
--Other useful SFDC columns
SFDC_district_state_initiative,
SFDC_state_eligible_or_initiative,
SFDC_state_initiative,
SFDC_urban_rural,
--District (some parent account info)
SFDC_state_initiative_district,
SFDC_district_state_initiative_district,
SFDC_state_eligible_or_initiative_district,
loaddate
from {{ ref('dim_account') }}
where SFDC_org_type = 'School'
or LCOM_organization_type='district' /*districts like default values instead of*/
or account_id = '{{ var("default_ID") }}' /*default account*/


