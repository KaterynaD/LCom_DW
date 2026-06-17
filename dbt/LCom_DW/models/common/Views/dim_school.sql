{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
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
SFDC_parent_id SFDC_District_Id,
SFDC_parent_name SFDC_District_Name,
SFDC_created_date,
SFDC_last_modified_date,
SFDC_school_enrollment,
--Other useful SFDC columns
SFDC_district_state_initiative,
SFDC_state_initiative,
SFDC_urban_rural,
--District (some parent account info)
SFDC_state_initiative_district,
SFDC_district_state_initiative_district,
isHighSchool,
loaddate
from {{ ref('dim_account') }}



