{{
    config(

        materialized='table',        
        dist='account_id', 
        sort='account_id',
        post_hook=['{{ update_DIM_ACCOUNT_HISTORY_changed_UK() }}'],        
		sql_header = 'SET enable_numeric_rounding TO ON;'                          
        )
}}



with LCOM_data as (
    select * from {{ ref('int_dim_account_lcom') }}
), SFDC_data as (
    select * from {{ ref('int_dim_account_sfdc') }}
), data as (
select
    coalesce(LCOM_data.organization_id, SFDC_data.Id) as account_id,
--LCOM columns
isnull(LCOM_data.organization_id, '{{ var("default_ID") }}') as  lcom_organization_id,
isnull(LCOM_data.organization_name, '{{ var("default_varchar") }}') as  lcom_organization_name,
isnull(LCOM_data.organization_type, '{{ var("default_varchar") }}') as  lcom_organization_type,
isnull(LCOM_data.parent_organization_id, '{{ var("default_ID") }}') as  lcom_parent_organization_id,
isnull(LCOM_data.parent_organization_name, '{{ var("default_varchar") }}') as  lcom_parent_organization_name,
isnull(LCOM_data.is_trial, {{ var("default_boolean") }}) as  lcom_trial,
isnull(LCOM_data.is_demo, {{ var("default_boolean") }}) as  lcom_demo,
isnull(LCOM_data.postal_code, '{{ var("default_varchar") }}') as  lcom_postal_code,
isnull(LCOM_data.state_province_key, '{{ var("default_varchar") }}') as  lcom_state_province_key,
isnull(LCOM_data.state_province_code, '{{ var("default_varchar") }}') as  lcom_state_province_code,
isnull(LCOM_data.state_province_name, '{{ var("default_varchar") }}') as  lcom_state_province_name,
isnull(LCOM_data.country_code, '{{ var("default_varchar") }}')  as lcom_country_code,
isnull(LCOM_data.country_name, '{{ var("default_varchar") }}') as  lcom_country_name,
isnull(LCOM_data.alpha3_code, '{{ var("default_varchar") }}') as  lcom_alpha3_code,
isnull(LCOM_data.numeric_code, '{{ var("default_varchar") }}') as  lcom_numeric_code,
isnull(LCOM_data.external_sis_id, '{{ var("default_varchar") }}') as  lcom_external_sis_id,
isnull(LCOM_data.nces_id, '{{ var("default_varchar") }}')  as lcom_nces_id,
isnull(LCOM_data.created_datetime, '{{ var("default_date") }}') as  lcom_created_datetime,
isnull(LCOM_data.modified_datetime, '{{ var("default_date") }}')  as lcom_modified_datetime,
isnull(LCOM_data.deleted_datetime, '{{ var("default_date") }}')  as lcom_deleted_datetime,
--SFDC columns
coalesce(LCOM_data.SFDC_account_id, SFDC_data.Id, '{{ var("default_varchar") }}') as SFDC_account_id,
isnull(SFDC_data.name, '{{ var("default_varchar") }}') as SFDC_name,
isnull(SFDC_data.alt_phone_c, '{{ var("default_varchar") }}') as SFDC_alt_phone,
isnull(sfdc_data.billing_country, '{{ var("default_varchar") }}') as SFDC_billing_country,
isnull(sfdc_data.billing_country_code, '{{ var("default_varchar") }}') as SFDC_billing_country_code,
isnull(SFDC_data.billing_state, '{{ var("default_varchar") }}') as SFDC_billing_state,
isnull(SFDC_data.billing_state_code, '{{ var("default_varchar") }}') as SFDC_billing_state_code,
isnull(SFDC_data.category_c, '{{ var("default_varchar") }}') as SFDC_category,
isnull(SFDC_data.churn_date_c, '{{ var("default_date") }}') as SFDC_churn_date,
isnull(SFDC_data.churned_opportunity_id_c, '{{ var("default_varchar") }}') as SFDC_churned_opportunity_id,
isnull(SFDC_data.county_name_c, '{{ var("default_varchar") }}') as SFDC_county_name,
isnull(SFDC_data.created_by_id, '{{ var("default_varchar") }}') as SFDC_created_by_id,
isnull(SFDC_data.created_date AT TIME ZONE 'PST', '{{ var("default_date") }}') as SFDC_created_date,
isnull(SFDC_data.current_renewal_arr_c, {{ var("default_numeric") }}) as SFDC_current_renewal_arr,
isnull(SFDC_data.customer_type_c, '{{ var("default_varchar") }}') as SFDC_customer_type,
isnull(case
	when SFDC_data.customer_level_c is null
		then
			case when SFDC_data.tier_c = 'Ecommerce'		then 'eComm'
			when SFDC_data.tier_c = 'Emerging' then 'Emerging Account'
			when SFDC_data.tier_c = 'Key' then 'Key Account'
			when SFDC_data.tier_c = 'Midmarket' then 'Mid-Market Account'
			when SFDC_data.tier_c = 'Specialty' then 'Specialty Account'
			else SFDC_data.customer_level_c
			end
	else SFDC_data.customer_level_c
end 
, '{{ var("default_varchar") }}') as SFDC_customer_level,
isnull(SFDC_data.customer_level_override_c, '{{ var("default_varchar") }}') as SFDC_customer_level_override,
isnull(SFDC_data.grade_levels_c, '{{ var("default_varchar") }}') as SFDC_grade_levels,
isnull(SFDC_data.de_identified_district_c, {{ var("default_boolean") }}) as SFDC_de_identified_district,
isnull(SFDC_data.description, '{{ var("default_varchar") }}') as SFDC_description,
isnull(SFDC_data.district_enrollment_c, {{ var("default_numeric") }}) as SFDC_district_enrollment,
isnull(SFDC_data.district_state_initiative_c, {{ var("default_boolean") }}) as SFDC_district_state_initiative,
isnull(SFDC_data.k_12_enrollment_c, {{ var("default_numeric") }}) as SFDC_k_12_enrollment,
isnull(SFDC_data.k_5_enrollment_c, {{ var("default_numeric") }}) as SFDC_k_5_enrollment,
isnull(SFDC_data.k_8_enrollment_c, {{ var("default_numeric") }}) as SFDC_k_8_enrollment,
isnull(SFDC_data.kindergarten_enrollment_c, {{ var("default_numeric") }}) as SFDC_kindergarten_enrollment,
isnull(SFDC_data.pre_k_enrollment_c, {{ var("default_numeric") }}) as SFDC_pre_k_enrollment,
isnull(SFDC_data.last_modified_by_id, '{{ var("default_varchar") }}') as SFDC_last_modified_by_id,
isnull(SFDC_data.last_modified_date AT TIME ZONE 'PST', '{{ var("default_date") }}') as SFDC_last_modified_date,
isnull(SFDC_data.last_name_c, '{{ var("default_varchar") }}') as SFDC_last_name,
isnull(SFDC_data.lcom_account_c, '{{ var("default_varchar") }}') as SFDC_lcom_account,
isnull(SFDC_data.lcom_account_class_c, '{{ var("default_varchar") }}') as SFDC_lcom_account_class,
isnull(SFDC_data.lcom_account_count_c, {{ var("default_numeric") }}) as SFDC_lcom_account_count,
isnull(SFDC_data.lcom_organization_c, '{{ var("default_varchar") }}') as SFDC_lcom_organization,
isnull(SFDC_data.lcom_organization_count_c, {{ var("default_numeric") }}) as SFDC_lcom_organization_count,
isnull(SFDC_data.lcom_organization_has_parent_c, {{ var("default_boolean") }}) as SFDC_lcom_organization_has_parent,
isnull(SFDC_data.name_with_lcom_organization_info_c, '{{ var("default_varchar") }}') as SFDC_name_with_lcom_organization_info,
isnull(SFDC_data.owner_id, '{{ var("default_varchar") }}') as SFDC_owner_id,
isnull(SFDC_data.owner_name_text_c, '{{ var("default_varchar") }}') as SFDC_owner_name_text,
isnull(SFDC_data.parent_churned_c, {{ var("default_boolean") }}) as SFDC_parent_churned,
isnull(SFDC_data.parent_id, '{{ var("default_ID") }}') as SFDC_parent_id,
isnull(SFDC_data.parent_name_proper_case_c, '{{ var("default_varchar") }}') as SFDC_parent_name,
isnull(SFDC_data.phone, '{{ var("default_varchar") }}') as SFDC_phone,
isnull(SFDC_data.record_type_c, '{{ var("default_varchar") }}') as SFDC_record_type,
isnull(SFDC_data.school_enrollment_c, {{ var("default_numeric") }}) as SFDC_school_enrollment,
isnull(SFDC_data.state_initiative_c, {{ var("default_boolean") }}) as SFDC_state_initiative,
isnull(SFDC_data.state_program_eligible_c, {{ var("default_boolean") }}) as SFDC_state_program_eligible,
isnull(SFDC_data.ultimate_account_owner_c, '{{ var("default_varchar") }}') as SFDC_ultimate_account_owner,
isnull(SFDC_data.ultimate_parent_account_c, '{{ var("default_varchar") }}') as SFDC_ultimate_parent_account,
isnull(SFDC_data.ultimate_parent_billing_state_c, '{{ var("default_varchar") }}') as SFDC_ultimate_parent_billing_state,
isnull(SFDC_data.ultimate_parent_id_c, '{{ var("default_ID") }}') as SFDC_ultimate_parent_id,
isnull(SFDC_data.urban_rural_c, '{{ var("default_varchar") }}') as SFDC_urban_rural,
isnull(SFDC_data.lcom_organization_id, '{{ var("default_varchar") }}') as  SFDC_lcom_organization_id,
--
isnull(SFDC_data.technology_measure_c, '{{ var("default_varchar") }}') as SFDC_technology_measure,
isnull(SFDC_data.account_grade_c, '{{ var("default_varchar") }}') as SFDC_account_grade,
isnull(SFDC_data.fiscal_title_i_school_yes_no_c, '{{ var("default_varchar") }}') as SFDC_fiscal_title_i_school_yes_no,
isnull(SFDC_data.title_iv_funding_21_st_century_grants_c, '{{ var("default_varchar") }}') as SFDC_title_iv_funding_21_st_century_grants,
isnull(SFDC_data.title_iv_funding_student_support_c, '{{ var("default_varchar") }}') as SFDC_title_iv_funding_student_support,
isnull(SFDC_data.pct_asian_c ,  {{ var("default_numeric") }}) as SFDC_pct_asian,
isnull(SFDC_data.pct_afro_amer_c ,  {{ var("default_numeric") }}) as SFDC_pct_afro_amer,
isnull(SFDC_data.pct_white_c,  {{ var("default_numeric") }}) as SFDC_pct_white,
isnull(SFDC_data.pct_hisp_c,  {{ var("default_numeric") }}) as SFDC_pct_hisp,
isnull(SFDC_data.pct_multi_racial_c,    {{ var("default_numeric") }}) as SFDC_pct_multi_racial,
isnull(SFDC_data.pct_native_c,  {{ var("default_numeric") }}) as SFDC_pct_native,
isnull(SFDC_data.pct_pacific_c , {{ var("default_numeric") }}) as SFDC_pct_pacific,
--
isnull(SFDC_data.district_easy_code_tam_c::double precision, {{ var("default_numeric") }}) as SFDC_district_easy_code_tam,
isnull(SFDC_data.district_easy_tech_tam_c::double precision, {{ var("default_numeric") }}) as SFDC_district_easy_tech_tam,
isnull(SFDC_data.district_total_tam_c::double precision, {{ var("default_numeric") }}) as SFDC_district_total_tam,
isnull(SFDC_data.district_expansion_potential_c::double precision, {{ var("default_numeric") }}) as SFDC_district_expansion_potential,
isnull(SFDC_data.schools_in_district_c::integer, {{ var("default_numeric") }}) as SFDC_schools_in_district,
isnull(SFDC_data.free_lunch_students_c::integer, {{ var("default_numeric") }}) as SFDC_free_lunch_students,
isnull(SFDC_data.reduced_lunch_student_c::integer, {{ var("default_numeric") }}) as SFDC_reduced_lunch_students,
--
--School (some child accounts info)
isnull(SFDC_data.state_initiative_school, {{ var("default_boolean") }}) as SFDC_state_initiative_school,
isnull(SFDC_data.district_state_initiative_school, {{ var("default_boolean") }}) as SFDC_district_state_initiative_school,
--District (some parent account info)
isnull(SFDC_data.state_initiative_district, {{ var("default_boolean") }}) as SFDC_state_initiative_district,
isnull(SFDC_data.district_state_initiative_district, {{ var("default_boolean") }}) as SFDC_district_state_initiative_district,
--Calculated
case when (SFDC_data.grade_levels_c = 'High School' or (SFDC_data.grade_levels_c is null and  SFDC_data.k_12_enrollment_c>0 and SFDC_data.k_8_enrollment_c=0)) then True else False end as isHighSchool
--
,isnull(SFDC_data.total_won_opportunities, {{ var("default_numeric") }}) as total_won_opportunities
,isnull(SFDC_data.total_open_opportunities, {{ var("default_numeric") }}) as total_open_opportunities
,isnull(SFDC_data.latest_start_date, '{{ var("default_date") }}') as latest_start_date
,isnull(SFDC_data.latest_end_date, '{{ var("default_date") }}') as latest_end_date
,isnull(SFDC_data.latest_open_opportunities_modified_date, '{{ var("default_date") }}') as latest_open_opportunities_modified_date
,isnull(SFDC_data.first_invoiced_date, '{{ var("default_date") }}') as first_invoiced_date
,isnull(SFDC_data.total_training_sessions, {{ var("default_numeric") }}) as total_training_sessions
,isnull(SFDC_data.latest_training_session_on, '{{ var("default_date") }}') as latest_training_session_on
,isnull(SFDC_data.total_cases, {{ var("default_numeric") }}) as total_cases
,isnull(SFDC_data.currently_open_cases, {{ var("default_numeric") }}) as currently_open_cases
,isnull(SFDC_data.latest_case_created_date, '{{ var("default_date") }}') as latest_case_created_date
,isnull(SFDC_data.latest_open_case_modified_date, '{{ var("default_date") }}') as latest_open_case_modified_date
--
FROM LCOM_data
--
full outer join SFDC_data
on LCOM_data.salesforce_id = SFDC_data.Id



/*add default values for the first run only*/

union all
/*default*/
select 
--LCOM columns
'{{ var("default_ID") }}' as account_id,
'{{ var("default_ID") }}' as lcom_organization_id,
'{{ var("default_varchar") }}' as  lcom_organization_name,
'{{ var("default_varchar") }}' as  lcom_organization_type,
'{{ var("default_ID") }}' as  lcom_parent_organization_id,
'{{ var("default_varchar") }}' as  lcom_parent_organization_name,
{{ var("default_boolean") }} as  lcom_trial,
{{ var("default_boolean") }} as  lcom_demo,
'{{ var("default_varchar") }}' as  lcom_postal_code,
'{{ var("default_varchar") }}' as  lcom_state_province_key,
'{{ var("default_varchar") }}' as  lcom_state_province_code,
'{{ var("default_varchar") }}' as  lcom_state_province_name,
'{{ var("default_varchar") }}' as  lcom_country_code,
'{{ var("default_varchar") }}' as  lcom_country_name,
'{{ var("default_varchar") }}' as  lcom_alpha3_code,
'{{ var("default_varchar") }}' as  lcom_numeric_code,
'{{ var("default_varchar") }}' as  lcom_external_sis_id,
'{{ var("default_varchar") }}' as  lcom_nces_id,
'{{ var("default_date") }}' lcom_created_datetime,
'{{ var("default_date") }}' lcom_modified_datetime,
'{{ var("default_date") }}' lcom_deleted_datetime,
--SFDC columns
'{{ var("default_ID") }}' as SFDC_account_id,
'{{ var("default_varchar") }}' as SFDC_name,
'{{ var("default_varchar") }}' as SFDC_alt_phone ,
'{{ var("default_varchar") }}' as SFDC_billing_country,
'{{ var("default_varchar") }}' as SFDC_billing_country_code,
'{{ var("default_varchar") }}'  as SFDC_billing_state,
'{{ var("default_varchar") }}'  as SFDC_billing_state_code,
'{{ var("default_varchar") }}' as SFDC_category ,
'{{ var("default_date") }}'    as SFDC_churn_date,
'{{ var("default_varchar") }}' as SFDC_churned_opportunity_id,
'{{ var("default_varchar") }}' as SFDC_county_name ,
'{{ var("default_varchar") }}' as SFDC_created_by_id ,
'{{ var("default_date") }}' as SFDC_created_date ,
{{ var("default_numeric") }}   as   SFDC_current_renewal_arr ,
'{{ var("default_varchar") }}' as SFDC_customer_type ,
'{{ var("default_varchar") }}' as SFDC_customer_level,
'{{ var("default_varchar") }}' as SFDC_customer_level_override,
'{{ var("default_varchar") }}' as SFDC_grade_levels ,
{{ var("default_boolean") }}   as   SFDC_de_identified_district ,
'{{ var("default_varchar") }}' as SFDC_description ,
{{ var("default_numeric") }}   as   SFDC_district_enrollment ,
{{ var("default_boolean") }}   as   SFDC_district_state_initiative ,
{{ var("default_numeric") }}   as   SFDC_k_12_enrollment ,
{{ var("default_numeric") }}   as   SFDC_k_5_enrollment ,
{{ var("default_numeric") }}   as   SFDC_k_8_enrollment ,
{{ var("default_numeric") }}   as   SFDC_kindergarten_enrollment ,
{{ var("default_numeric") }}   as   SFDC_pre_k_enrollment ,
'{{ var("default_varchar") }}' as SFDC_last_modified_by_id ,
'{{ var("default_date") }}' as SFDC_last_modified_date ,
'{{ var("default_varchar") }}' as SFDC_last_name ,
'{{ var("default_varchar") }}' as SFDC_lcom_account ,
'{{ var("default_varchar") }}' as SFDC_lcom_account_class ,
{{ var("default_numeric") }}   as   SFDC_lcom_account_count ,
'{{ var("default_varchar") }}' as SFDC_lcom_organization ,
{{ var("default_numeric") }}   as   SFDC_lcom_organization_count ,
{{ var("default_boolean") }}   as   SFDC_lcom_organization_has_parent ,
'{{ var("default_varchar") }}' as SFDC_name_with_lcom_organization_info ,
'{{ var("default_varchar") }}' as SFDC_owner_id ,
'{{ var("default_varchar") }}' as SFDC_owner_name_text ,
{{ var("default_boolean") }}   as   SFDC_parent_churned ,
'{{ var("default_ID") }}'      as SFDC_parent_id ,
'{{ var("default_varchar") }}' as SFDC_parent_name ,
'{{ var("default_varchar") }}' as SFDC_phone ,
'{{ var("default_varchar") }}' as SFDC_record_type ,
{{ var("default_numeric") }}   as   SFDC_school_enrollment ,
{{ var("default_boolean") }}   as   SFDC_state_initiative ,
{{ var("default_boolean") }}   as   SFDC_state_program_eligible ,
'{{ var("default_varchar") }}' as SFDC_ultimate_account_owner ,
'{{ var("default_varchar") }}' as SFDC_ultimate_parent_account ,
'{{ var("default_varchar") }}' as SFDC_ultimate_parent_billing_state ,
'{{ var("default_ID") }}' as SFDC_ultimate_parent_id ,
'{{ var("default_varchar") }}' as SFDC_urban_rural ,
'{{ var("default_varchar") }}'  as   SFDC_lcom_organization_id,
--
'{{ var("default_varchar") }}' as SFDC_technology_measure,
'{{ var("default_varchar") }}' as SFDC_account_grade,
'{{ var("default_varchar") }}' as SFDC_fiscal_title_i_school_yes_no,
'{{ var("default_varchar") }}' as SFDC_title_iv_funding_21_st_century_grants,
'{{ var("default_varchar") }}' as SFDC_title_iv_funding_student_support,
{{ var("default_numeric") }} as SFDC_pct_asian,
{{ var("default_numeric") }} as SFDC_pct_afro_amer,
{{ var("default_numeric") }} as SFDC_pct_white,
{{ var("default_numeric") }} as SFDC_pct_hisp,
{{ var("default_numeric") }} as SFDC_pct_multi_racial,
{{ var("default_numeric") }} as SFDC_pct_native,
{{ var("default_numeric") }} as SFDC_pct_pacific,
--
{{ var("default_numeric") }} as SFDC_district_easy_code_tam,
{{ var("default_numeric") }} as SFDC_district_easy_tech_tam,
{{ var("default_numeric") }} as SFDC_district_total_tam,
{{ var("default_numeric") }} as SFDC_district_expansion_potential,
{{ var("default_numeric") }} as SFDC_schools_in_district,
{{ var("default_numeric") }} as SFDC_free_lunch_students,
{{ var("default_numeric") }} as SFDC_reduced_lunch_students,
--
--School (some child accounts info)
{{ var("default_boolean") }} as SFDC_state_initiative_school,
{{ var("default_boolean") }} as SFDC_district_state_initiative_school,
--District (some parent account info)
{{ var("default_boolean") }} as SFDC_state_initiative_district,
{{ var("default_boolean") }} as SFDC_district_state_initiative_district,
--Calculated
{{ var("default_boolean") }} as isHighSchool
 ,{{ var("default_numeric") }} as total_won_opportunities
 ,{{ var("default_numeric") }} as total_open_opportunities
 ,'{{ var("default_date") }}' as latest_start_date
 ,'{{ var("default_date") }}' as latest_end_date
 ,'{{ var("default_date") }}' as latest_open_opportunities_modified_date
 ,'{{ var("default_date") }}' as first_invoiced_date
 ,{{ var("default_numeric") }} as total_training_sessions
 ,'{{ var("default_date") }}' as latest_training_session_on
 ,{{ var("default_numeric") }} as total_cases
 ,{{ var("default_numeric") }} as currently_open_cases
 ,'{{ var("default_date") }}' as latest_case_created_date
 ,'{{ var("default_date") }}' as latest_open_case_modified_date
)
select
    account_id::varchar(300),
    lcom_organization_id :: varchar(300),
    lcom_organization_name :: varchar(270),
    lcom_organization_type :: varchar(20),
    lcom_parent_organization_id :: varchar(300),
    lcom_parent_organization_name :: varchar(270),
    lcom_trial :: boolean,
    lcom_demo :: boolean,
    lcom_postal_code :: varchar(20),
    lcom_state_province_key :: varchar(20),
    lcom_state_province_code :: varchar(20),
    lcom_state_province_name :: varchar(50),
    lcom_country_code :: varchar(20),
    lcom_country_name :: varchar(70),
    lcom_alpha3_code :: varchar(20),
    lcom_numeric_code :: varchar(20),
    lcom_external_sis_id :: varchar(270),
    lcom_nces_id :: varchar(30),
    lcom_created_datetime :: timestamp,
    lcom_modified_datetime :: timestamp,
    lcom_deleted_datetime :: timestamp,
    sfdc_account_id :: varchar(300),
    sfdc_name :: varchar(780),
    sfdc_alt_phone :: varchar(130),
    sfdc_billing_country :: varchar(240),
    sfdc_billing_country_code :: varchar(30),
    sfdc_billing_state :: varchar(240),
    sfdc_billing_state_code :: varchar(30),
    sfdc_category :: varchar(780),
    sfdc_churn_date::date,
    sfdc_churned_opportunity_id:: varchar(765),
    sfdc_county_name :: varchar(780),
    sfdc_created_by_id :: varchar(30),
    sfdc_created_date :: timestamp,
    round(sfdc_current_renewal_arr::numeric(38,10), 2) :: numeric(16,2) as sfdc_current_renewal_arr,
    sfdc_customer_type :: varchar(20),
    sfdc_customer_level :: varchar(765),
    sfdc_customer_level_override :: varchar(765),
    sfdc_grade_levels :: varchar(100),
    sfdc_de_identified_district :: boolean,
    sfdc_description :: varchar(max),
    sfdc_district_state_initiative :: boolean,
    round(sfdc_district_enrollment::numeric(38,10), 0) :: integer as sfdc_district_enrollment,
    round(sfdc_k_12_enrollment::numeric(38,10), 0) :: integer as sfdc_k_12_enrollment,
    round(sfdc_k_5_enrollment::numeric(38,10), 0) :: integer as sfdc_k_5_enrollment,
    round(sfdc_k_8_enrollment::numeric(38,10), 0) :: integer as sfdc_k_8_enrollment,
    round(sfdc_kindergarten_enrollment::numeric(38,10), 0) :: integer as sfdc_kindergarten_enrollment,
    round(sfdc_pre_k_enrollment::numeric(38,10), 0) :: integer as sfdc_pre_k_enrollment,
    sfdc_last_modified_by_id :: varchar(30),
    sfdc_last_modified_date :: timestamp,
    sfdc_last_name :: varchar(780),
    sfdc_lcom_account :: varchar(30),
    sfdc_lcom_account_class :: varchar(780),
    sfdc_lcom_account_count :: bigint,
    sfdc_lcom_organization :: varchar(30),
    sfdc_lcom_organization_count :: bigint,
    sfdc_lcom_organization_has_parent :: boolean,
    sfdc_name_with_lcom_organization_info :: varchar(1280),
    sfdc_owner_id :: varchar(30),
    sfdc_owner_name_text :: varchar(380),
    sfdc_parent_churned :: boolean,
    sfdc_parent_id :: varchar(300),
    sfdc_parent_name :: varchar(370),
    sfdc_phone :: varchar(130),
    sfdc_record_type :: varchar(780),
    round(sfdc_school_enrollment::numeric(38,10), 0) :: integer as sfdc_school_enrollment,
    sfdc_state_initiative :: boolean,
    sfdc_state_program_eligible :: boolean,
    sfdc_ultimate_account_owner :: varchar(380),
    sfdc_ultimate_parent_account :: varchar(780),
    sfdc_ultimate_parent_billing_state :: varchar(250),
    sfdc_ultimate_parent_id :: varchar(300),
    sfdc_urban_rural :: varchar(40),
    sfdc_lcom_organization_id :: varchar(300),
    sfdc_technology_measure :: varchar(60),
    sfdc_account_grade :: varchar(15),
    sfdc_fiscal_title_i_school_yes_no :: varchar(765),
    sfdc_title_iv_funding_21_st_century_grants :: varchar(192),
    sfdc_title_iv_funding_student_support :: varchar(256),
    round(sfdc_pct_asian::numeric(38,10), 4) :: numeric(16,4) as sfdc_pct_asian,
    round(sfdc_pct_afro_amer::numeric(38,10), 4) :: numeric(16,4) as sfdc_pct_afro_amer,
    round(sfdc_pct_white::numeric(38,10), 4) :: numeric(16,4) as sfdc_pct_white,
    round(sfdc_pct_hisp::numeric(38,10), 4) :: numeric(16,4) as sfdc_pct_hisp,
    round(sfdc_pct_multi_racial::numeric(38,10), 4) :: numeric(16,4) as sfdc_pct_multi_racial,
    round(sfdc_pct_native::numeric(38,10), 4) :: numeric(16,4) as sfdc_pct_native,
    round(sfdc_pct_pacific::numeric(38,10), 4) :: numeric(16,4) as sfdc_pct_pacific,
    --
    round(sfdc_district_easy_code_tam::numeric(38,10), 2) :: numeric(16,2) as sfdc_district_easy_code_tam,
    round(sfdc_district_easy_tech_tam::numeric(38,10), 2) :: numeric(16,2) as sfdc_district_easy_tech_tam,
    round(sfdc_district_total_tam::numeric(38,10), 2) :: numeric(16,2) as sfdc_district_total_tam,
    round(sfdc_district_expansion_potential::numeric(38,10), 2) :: numeric(16,2) as sfdc_district_expansion_potential,
    round(sfdc_schools_in_district::numeric(38,10), 0) :: integer as sfdc_schools_in_district,
    round(sfdc_free_lunch_students::numeric(38,10), 0) :: integer as sfdc_free_lunch_students,
    round(sfdc_reduced_lunch_students::numeric(38,10), 0) :: integer as sfdc_reduced_lunch_students,
    --
    sfdc_state_initiative_school :: boolean,
    sfdc_district_state_initiative_school :: boolean,
    sfdc_state_initiative_district :: boolean,
    sfdc_district_state_initiative_district :: boolean,
    --Calculated
    isHighSchool:: boolean,
    total_won_opportunities::integer,
    total_open_opportunities::integer,
    latest_start_date::date,
    latest_end_date::date,
    latest_open_opportunities_modified_date::date,
    first_invoiced_date::date,
    total_training_sessions::integer,
    latest_training_session_on::date,
    total_cases::integer,
    currently_open_cases::integer,
    latest_case_created_date::date,
    latest_open_case_modified_date::date,
    '{{ var("loaddate") }}'::timestamp as loaddate
FROM data
