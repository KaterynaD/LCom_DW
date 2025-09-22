{{ config(materialized='view',
   bind=False
)
 }}

select 
account_id as district_id,
--LCOM columns
lcom_organization_id as Lcom_district_id,
lcom_organization_name as LCOM_District_Name,
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
--Salesforce columns only populated for districts
sfdc_account_id as SFDC_district_id,
SFDC_name as SFDC_District_Name,
SFDC_created_date	,
SFDC_last_modified_date	,
SFDC_account_last_activity_date	,
SFDC_activity_metric_rollup_id	,
SFDC_agile_lms	,
SFDC_alt_phone	,
SFDC_cares_act_allocation	,
sfdc_county_name,
SFDC_district	,
SFDC_district_easy_code_tam	,
SFDC_district_easy_tech_tam	,
SFDC_district_elementary_teachers	,
SFDC_district_faculty_library_media_fte	,
SFDC_district_kindergarten_teachers	,
SFDC_easy_tech_tam	,
SFDC_easy_tech_tam_captured	,
SFDC_fiscal_career_and_tech_federal	,
SFDC_fiscal_career_and_tech_state	,
SFDC_fiscal_career_and_tech_teacher_salar	,
SFDC_i_pad_schools_percent	,
SFDC_last_activity_date	,
SFDC_last_activity_logged_on	,
SFDC_number_of_schools	,
SFDC_number_of_elementary_schools,
SFDC_number_of_high_schools,
SFDC_number_of_k_8_buildings,
SFDC_number_of_middle_schools,
SFDC_number_of_title_i_schools,
SFDC_parent_gsid	,
SFDC_technology_equipment	,
SFDC_technology_supplies_and_purchases	,
SFDC_type	,
SFDC_district_enrollment,
SFDC_school_enrollment,
--Other useful SFDC columns
sfdc_state_program_eligible ,
SFDC_district_state_initiative	,
SFDC_state_initiative	,
SFDC_urban_rural,
SFDC_owner_name_text,
-- some School level SFDC info
SFDC_state_initiative_school,
SFDC_district_state_initiative_school,
--
loaddate
--
from {{ ref('dim_account') }}
where SFDC_record_type='L'
or LCOM_organization_type='district'
or account_id = '{{ var("default_ID") }}' /*default account*/