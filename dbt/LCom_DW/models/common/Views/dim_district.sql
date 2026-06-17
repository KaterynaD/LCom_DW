{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
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
SFDC_ULTIMATE_PARENT_ID,
SFDC_ultimate_parent_account,
SFDC_created_date	,
SFDC_last_modified_date	,
sfdc_county_name,
SFDC_district_enrollment,
SFDC_school_enrollment,
--Other useful SFDC columns
sfdc_state_program_eligible ,
SFDC_district_state_initiative	,
SFDC_state_initiative	,
SFDC_urban_rural,
SFDC_owner_name_text,
sfdc_account_grade ,
sfdc_current_renewal_arr ,
sfdc_customer_level ,
sfdc_fiscal_title_i_school_yes_no ,
sfdc_pct_afro_amer ,
sfdc_pct_asian ,
sfdc_pct_hisp ,
sfdc_pct_multi_racial ,
sfdc_pct_native ,
sfdc_pct_pacific ,
sfdc_pct_white ,
sfdc_technology_measure ,
sfdc_title_iv_funding_21_st_century_grants ,
sfdc_title_iv_funding_student_support ,
sfdc_ultimate_parent_current_renewal_arr ,
sfdc_district_easy_code_tam ,
sfdc_district_easy_tech_tam ,
sfdc_district_total_tam ,
sfdc_district_expansion_potential ,
sfdc_schools_in_district ,
sfdc_free_lunch_students ,
sfdc_reduced_lunch_students ,
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