{% docs column_lcom_organization_id %}
LCOM Organization ID Can be skew with default values if an account does not exist in LCOM Platform. Can be used in joins with LCOM related tables but better use account_id because it's a distribution key
{% enddocs %}

{% docs column_lcom_organization_name %}
LCOM Organization Name
{% enddocs %}

{% docs column_lcom_organization_type %}
LCOM Organization Type (school or district)
{% enddocs %}

{% docs column_lcom_parent_organization_id %}
LCOM Parent Organization Id (district Id)
{% enddocs %}

{% docs column_lcom_parent_organization_name %}
LCOM Parent Organization Name (district name)
{% enddocs %}

{% docs column_lcom_trial %}
Trial use of LCOM products
{% enddocs %}

{% docs column_lcom_demo %}
Demo use of LCOM products
{% enddocs %}

{% docs column_sfdc_name %}
Account Name
{% enddocs %}

{% docs column_sfdc_account_last_activity_date %}
Account Last Activity Date
{% enddocs %}

{% docs column_sfdc_account_management_type %}
Account Management Type
{% enddocs %}

{% docs column_sfdc_act_id %}
act id
{% enddocs %}

{% docs column_sfdc_actively_prospecting %}
Actively Prospecting (Mark if this is a customer you are actively prospecting but not yet at an opportunity stage)
{% enddocs %}

{% docs column_sfdc_activity_metric_id %}
Activity Metric
{% enddocs %}

{% docs column_sfdc_activity_metric_rollup_id %}
Activity Metric Rollup
{% enddocs %}

{% docs column_sfdc_ae_or_isr %}
AE OR ISR
{% enddocs %}

{% docs column_sfdc_agile_id %}
Agile ID
{% enddocs %}

{% docs column_sfdc_agile_lms %}
Agile LMS (Agile LMS)
{% enddocs %}

{% docs column_sfdc_agileed_agile_ed_insert %}
Created By ConnectLink
{% enddocs %}

{% docs column_sfdc_agileed_agile_ed_key %}
ConnectLink Key
{% enddocs %}

{% docs column_sfdc_agileed_agile_ed_latest_update_date %}
ConnectLink Latest Update Date
{% enddocs %}

{% docs column_sfdc_agileed_agile_ed_parent_key %}
ConnectLink Parent Key
{% enddocs %}

{% docs column_sfdc_agileed_agile_ed_status %}
ConnectLink Status (The status of the record in the Agile-Ed database: A = Active, C = Closed, U = Unlicensed.)
{% enddocs %}

{% docs column_sfdc_agileed_agile_ed_up_to_date %}
ConnectLink Up To Date (Deprecated)
{% enddocs %}

{% docs column_sfdc_agileed_agileed_do_not_update %}
ConnectLink Do Not Update (If this field is checked, then only the record's ConnectLink Status and ConnectLink Last Sync fields wil be updated when the record is synced.)
{% enddocs %}

{% docs column_sfdc_agileed_connect_link_changed_personnel_titles %}
ConnectLink Changed Personnel Titles (The number of changed Personnel ConnectLink Titles under the Institution.)
{% enddocs %}

{% docs column_sfdc_agileed_connect_link_district_key %}
ConnectLink District Key
{% enddocs %}

{% docs column_sfdc_agileed_connect_link_file_type %}
ConnectLink File Type (The category of the Institution.)
{% enddocs %}

{% docs column_sfdc_agileed_connect_link_hierarchized_personnel %}
ConnectLink Hierarchized Personnel (The number of Personnel associated to the Institution by ConnectLink.)
{% enddocs %}

{% docs column_sfdc_agileed_connect_link_licensed_status %}
ConnectLink Licensed Status
{% enddocs %}

{% docs column_sfdc_agileed_connect_link_personnel_roles %}
ConnectLink Personnel Roles (The number of Personnel ConnectLink Roles under the Institution.)
{% enddocs %}

{% docs column_sfdc_agileed_connect_link_personnel_titles %}
ConnectLink Personnel Titles (The number of Personnel ConnectLink Titles under the Institution.)
{% enddocs %}

{% docs column_sfdc_agileed_last_sync %}
ConnectLink Last Sync Date
{% enddocs %}

{% docs column_sfdc_agileed_parent_pending %}
ConnectLink Parent Pending (If true, the parent record has not yet been inserted to create a hierarchy. Used in batch job to signal the need for parenting.)
{% enddocs %}

{% docs column_sfdc_agileed_personnel_last_sync %}
ConnectLink Personnel Last Sync (Timestamped after Contacts and/or Leads directly related to the Account are bulk-updated.)
{% enddocs %}

{% docs column_sfdc_alt_phone %}
Agile Phone
{% enddocs %}

{% docs column_sfdc_billing_country %}
Billing Country
{% enddocs %}

{% docs column_sfdc_billing_country_code %}
Billing Countrye Code
{% enddocs %}

{% docs column_sfdc_billing_state %}
Billing State
{% enddocs %}

{% docs column_sfdc_billing_state_code %}
Billing State Code
{% enddocs %}

{% docs column_sfdc_cares_act_allocation %}
CARES Act Allocation
{% enddocs %}

{% docs column_sfdc_category %}
Category
{% enddocs %}

{% docs column_sfdc_churn_date %}
Churn Date
{% enddocs %}

{% docs column_sfdc_churned_opportunity_id %}
Churned Opportunity ID
{% enddocs %}

{% docs column_sfdc_closed_district_tx_adoption %}
Closed District - TX Adoption (If checked, the district is a known closed district and can not be prospected outside of the IMA coordinator.)
{% enddocs %}

{% docs column_sfdc_code_monkey_customer %}
Code Monkey Customer (Converts the Number of Active Code Monkey Subscriptions field into a checkbox  Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_codester_id %}
CodesterID
{% enddocs %}

{% docs column_sfdc_codesters_account_to_be_migrated_to_prod %}
Codesters Account to be Migrated to Prod (Denotes if a Codesters account has been flagged to be migrated to prod.)
{% enddocs %}

{% docs column_sfdc_codesters_customer_2 %}
Codesters Customer (Converts the Number of Active Codesters Subscriptions field into a checkbox  Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_codesters_customer_dedupe_flag %}
Codesters Customer Dedupe Flag (Denotes if an account has been flagged as an active customer and should be prioritized for dedupe during migration. This field should not be migrated to prod and should be deprecated after the migration is complete (will happen automatically after sandbox refresh))
{% enddocs %}

{% docs column_sfdc_company_domain_name %}
Company Domain Name (Field that integrates with Hubspot for means of company identification and automatic contact association within Hubspot)
{% enddocs %}

{% docs column_sfdc_completed_onboarding %}
Completed Onboarding (Describes whether or not a new account has been onboarded.)
{% enddocs %}

{% docs column_sfdc_computer_os %}
Computer OS
{% enddocs %}

{% docs column_sfdc_contracted_roll_up %}
Contracted Roll Up
{% enddocs %}

{% docs column_sfdc_county_name %}
County Name (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_created_by_id %}
Created By
{% enddocs %}

{% docs column_sfdc_created_date %}
Created Date in PST
{% enddocs %}

{% docs column_sfdc_csm_email %}
CSM Email
{% enddocs %}

{% docs column_sfdc_csm_name %}
CSM Name
{% enddocs %}

{% docs column_sfdc_current_renewal_arr %}
Current Renewal ARR (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_current_total_ultimate_parent %}
Current / Total / Ultimate Parent (Combined ARR Renewal values. A field which converts three currency fields (Current Renewal ARR, Total Renewal ARR, Ultimate Parent Total Renewal ARR) into text and concat them into one custom, text formula field. For Sys Admins and Sales Support)
{% enddocs %}

{% docs column_sfdc_customer_type %}
Customer Type (Creates text value for Record Type field for easier user understanding  Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_customer_level %}
Customer Level. Strategic level of customer.  Integrations: Gainsight.
{% enddocs %}

{% docs column_sfdc_customer_level_override %}
Customer Level Override is used to allow CSMs to override the automation from the Customer Level Flow
{% enddocs %}

{% docs column_sfdc_data_quality_description %}
Data Quality Description
{% enddocs %}

{% docs column_sfdc_data_quality_score %}
Data Quality Score
{% enddocs %}

{% docs column_sfdc_de_identified_district %}
DeIdentified District?
{% enddocs %}

{% docs column_sfdc_description %}
Description (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_detailed_grade %}
Detailed Grade
{% enddocs %}

{% docs column_sfdc_district %}
District Segment Size (to be populated by rule looking at enrollment)
{% enddocs %}

{% docs column_sfdc_district_easy_code_tam %}
District EasyCode TAM (Total EasyCode TAM for a district based on sum of all children TAM values)
{% enddocs %}

{% docs column_sfdc_district_easy_tech_tam %}
District EasyTech TAM (Total EasyTech TAM for a district based on sum of all children TAM values  Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_district_elementary_teachers %}
District Elementary Teachers
{% enddocs %}

{% docs column_sfdc_district_enrollment %}
District Enrollment (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_district_expansion_potential %}
District Expansion Potential (If Total TAM is greater than current renewal ARR, display the delta, else display zero. System estimated upsell potential. Meant as a guideline only.)
{% enddocs %}

{% docs column_sfdc_district_faculty_library_media_fte %}
District Faculty - Library/Media FTE
{% enddocs %}

{% docs column_sfdc_district_instructional_expenditures %}
District Instructional Expenditures
{% enddocs %}

{% docs column_sfdc_district_k_8_enrollment %}
District K-8 Enrollment
{% enddocs %}

{% docs column_sfdc_district_kindergarten_teachers %}
District Kindergarten Teachers
{% enddocs %}

{% docs column_sfdc_district_local_revenue_cities %}
District Local Revenue Cities (Local revenue from cities and counties.)
{% enddocs %}

{% docs column_sfdc_district_local_revenue_other_leas %}
District Local Revenue Other LEAs (Local revenue from other school systems.)
{% enddocs %}

{% docs column_sfdc_district_local_revenue_other_taxes %}
District Local Revenue Other Taxes (Local revenue all other taxes.)
{% enddocs %}

{% docs column_sfdc_district_local_revenue_property_taxes %}
District Local Revenue Property Taxes (Local revenue from property taxes.)
{% enddocs %}

{% docs column_sfdc_district_nces %}
District NCES
{% enddocs %}

{% docs column_sfdc_district_presence %}
District Presence (Denotes, in percent, the number of provisioned buildings against the number of total buildings in the district.)
{% enddocs %}

{% docs column_sfdc_district_state_initiative %}
District State Initiative
{% enddocs %}

{% docs column_sfdc_district_total_capital_outlay %}
District Total Capital Outlay
{% enddocs %}

{% docs column_sfdc_district_total_expenditures %}
District Total Expenditures
{% enddocs %}

{% docs column_sfdc_district_total_expense_per_student %}
District Total Expense Per Student
{% enddocs %}

{% docs column_sfdc_district_total_fed_revenue %}
District Total Fed Revenue
{% enddocs %}

{% docs column_sfdc_district_total_local_revenue %}
District Total Local Revenue
{% enddocs %}

{% docs column_sfdc_district_total_revenue %}
District Total Revenue
{% enddocs %}

{% docs column_sfdc_district_total_state_revenue %}
District Total State Revenue
{% enddocs %}

{% docs column_sfdc_district_total_tam %}
District Total TAM (Total TAM for a district based on sum of all children ET and EC TAM values. Source values for EC and ET are populated by Gainsight rule)
{% enddocs %}

{% docs column_sfdc_district_type %}
District Type (This field is mapped and will sync with Agile/ConnectLink)
{% enddocs %}

{% docs column_sfdc_dq_opportunities %}
DQ - Opportunities (Roll up summary of all opportunities on the account)
{% enddocs %}

{% docs column_sfdc_easy_tech_customer %}
EasyTech Customer (Converts the Number of EasyTech Subscriptions field into a binary field  Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_easy_tech_tam %}
EasyTech TAM (Contains the estimated size of the EasyTech opportunity based on current pricing. This field is populated manually via dataloader once per year. This TAM only includes TAM for K-8 Enrollment as of November 2022.)
{% enddocs %}

{% docs column_sfdc_easy_tech_tam_captured %}
EasyTech TAM Captured (Ratio between Total Renewal ARR and total EasyTech TAM. This field is used to assign the sales owner based on the 33% threshold established during sales planning in November 2022)
{% enddocs %}

{% docs column_sfdc_ec_tam %}
EC TAM (Calculates TAM for EasyCode (using just Codesters))
{% enddocs %}

{% docs column_sfdc_education_climate_index %}
Education Climate Index
{% enddocs %}

{% docs column_sfdc_education_type %}
Education Type
{% enddocs %}

{% docs column_sfdc_eighth_grade_enrollment %}
8th Grade Enrollment (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_email_domain %}
Email Domain (Email domain field provided by Agile ed.)
{% enddocs %}

{% docs column_sfdc_enrollment_advanced_placement %}
Enrollment - Advanced Placement
{% enddocs %}

{% docs column_sfdc_enrollment_band %}
Enrollment Band (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_enrollment_tier %}
Enrollment Tier
{% enddocs %}

{% docs column_sfdc_esser_funding %}
ESSER Funding
{% enddocs %}

{% docs column_sfdc_et_tam %}
ET TAM (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_exes_campaign %}
Exes Campaign (For use in exes campaign 2022 - delete after use. Should be done by end of June 2022)
{% enddocs %}

{% docs column_sfdc_fifth_grade_enrollment %}
5th Grade Enrollment (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_first_grade_enrollment %}
1st Grade Enrollment (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_first_name %}
First Name (Used for NS Integration with Mulesoft - DO NOT EDIT)
{% enddocs %}

{% docs column_sfdc_fiscal_career_and_tech_federal %}
Fiscal - Career and Tech - Federal
{% enddocs %}

{% docs column_sfdc_fiscal_career_and_tech_state %}
Fiscal - Career and Tech - State
{% enddocs %}

{% docs column_sfdc_fiscal_career_and_tech_teacher_salar %}
Fiscal - Career and Tech - Teacher Salar
{% enddocs %}

{% docs column_sfdc_fiscal_title_i_eligible_school %}
Fiscal - Title I Eligible School
{% enddocs %}

{% docs column_sfdc_fiscal_title_i_funding %}
Fiscal - Title I Funding (Total Title I funding for the District)
{% enddocs %}

{% docs column_sfdc_fiscal_title_i_percentage %}
Fiscal - Title I Percentage
{% enddocs %}

{% docs column_sfdc_fiscal_title_i_school %}
Fiscal - Title I School (This is the appropriated district Title I funding that is based on the Title I population of a school)
{% enddocs %}

{% docs column_sfdc_fiscal_title_i_school_yes_no %}
Fiscal - Title I School - Yes No
{% enddocs %}

{% docs column_sfdc_fiscal_title_i_schoolwide %}
Fiscal - Title I Schoolwide
{% enddocs %}

{% docs column_sfdc_fiscal_title_i_schoolwide_yes_no %}
Fiscal - Title I Schoolwide - Yes No
{% enddocs %}

{% docs column_sfdc_free_lunch_students %}
Free Lunch Students
{% enddocs %}

{% docs column_sfdc_free_reduced_lunch %}
Free/Reduced Lunch % (% of Free + Reduced Lunch Students based on School Enrollment)
{% enddocs %}

{% docs column_sfdc_gainsight_customer %}
Gainsight Customer
{% enddocs %}

{% docs column_sfdc_gainsight_house %}
Gainsight House (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_google_integration %}
Google Integration (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_governor %}
Governor
{% enddocs %}

{% docs column_sfdc_governor_s_party_affiliation %}
Governor's Party Affiliation
{% enddocs %}

{% docs column_sfdc_grade_level_detail %}
Grade Level Detail
{% enddocs %}

{% docs column_sfdc_grade_levels %}
Grade Levels
{% enddocs %}

{% docs column_sfdc_has_codesters_child_accounts %}
Has Codesters Child Accounts (Denotes if an account has a migrated child customer of Codesters. This field should be deprecated by 12/31/2023)
{% enddocs %}

{% docs column_sfdc_hi_speed_classroom_internet %}
Hi Speed Classroom Internet
{% enddocs %}

{% docs column_sfdc_hi_speed_internet %}
Hi Speed Internet
{% enddocs %}

{% docs column_sfdc_hml_title_i_funding %}
HML Title I Funding (Title I Allocation)
{% enddocs %}

{% docs column_sfdc_hml_title_i_per_student %}
HML Title I Per Student (High Medium Low indicator of District Title I Allocation Per Student)
{% enddocs %}

{% docs column_sfdc_house_account %}
House Account (Check if Account is House Account)
{% enddocs %}

{% docs column_sfdc_i_pad_schools_percent %}
iPad Schools (Percent)
{% enddocs %}

{% docs column_sfdc_i_pads_for_instruction %}
iPads for Instruction
{% enddocs %}

{% docs column_sfdc_ima_coordinator_identified %}
IMA Coordinator Identified (Formula field checks to see if the IMA Coordinator has been completed. If blank, returns false. Used for 2024 TX Adoption.)
{% enddocs %}

{% docs column_sfdc_inst_uid %}
Agile Inst UID (The field is used to hold the data provided by Agile link in the excel for upload to SF.)
{% enddocs %}

{% docs column_sfdc_k_12_enrollment %}
K-12 Enrollment (Sums the agile enrollment fields by grade level)
{% enddocs %}

{% docs column_sfdc_k_5_enrollment %}
K-5 Enrollment (Captures total enrollment figures for grades K-5 based on Agile data.)
{% enddocs %}

{% docs column_sfdc_k_8_district_presence %}
K-8 District Presence (Denotes, in percent, the number of provisioned K-8 buildings against the number of total K-8 buildings in the district. This field is updated by Gainsight rule ADMIN - Set K-8 District Saturation child/no child 2.0 and refreshed nightly.)
{% enddocs %}

{% docs column_sfdc_k_8_enrollment %}
K-8 Enrollment (Captures total enrollment figures for grades K-8 based on Agile data)
{% enddocs %}

{% docs column_sfdc_key_account %}
Key Account (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_kindergarten_enrollment %}
Kindergarten Enrollment (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_known_duplicate %}
Known Duplicate (Use to flag duplicate accounts that need to be merged. Use this field to find duplicates with DuplicateCheck)
{% enddocs %}

{% docs column_sfdc_last_activity_date %}
Last Activity
{% enddocs %}

{% docs column_sfdc_last_activity_logged_on %}
Last Activity Logged On
{% enddocs %}

{% docs column_sfdc_last_modified_by_id %}
Last Modified By
{% enddocs %}

{% docs column_sfdc_last_modified_date %}
Last Modified Date in PST
{% enddocs %}

{% docs column_sfdc_last_name %}
Last Name (Used for NS Integration with Mulesoft - DO NOT EDIT)
{% enddocs %}

{% docs column_sfdc_lcom_account %}
LCOM Account (The LCOM Account associated with this account)
{% enddocs %}

{% docs column_sfdc_lcom_account_class %}
LCOM Account Class
{% enddocs %}

{% docs column_sfdc_lcom_account_count %}
LCOM Account Count (Returns the count of LCOM Accounts associated with this account. This value should always be either zero or one.)
{% enddocs %}

{% docs column_sfdc_lcom_organization %}
LCOM Organization (The associated LCOM Organization record for this account)
{% enddocs %}

{% docs column_sfdc_lcom_organization_count %}
LCOM Organization Count (Count of associated LCOM Organizations for a given account. This field should only ever have values of 0 or 1.)
{% enddocs %}

{% docs column_sfdc_lcom_organization_has_parent %}
LCOM Organization has Parent
{% enddocs %}

{% docs column_sfdc_learn_dash_code_sent %}
LearnDash Code Sent
{% enddocs %}

{% docs column_sfdc_les_opp %}
Les Opp (Denotes if an opp is part of Les Barnett's separation contractual obligation through 3/31/2021)
{% enddocs %}

{% docs column_sfdc_license_consumption %}
License Consumption (Current license consumption (based on Gainsight weekly usage))
{% enddocs %}

{% docs column_sfdc_map_tracker %}
Map Tracker (for manual use with maps to change colors of pins)
{% enddocs %}

{% docs column_sfdc_mdr_number %}
MDR Number
{% enddocs %}

{% docs column_sfdc_mi_pilot %}
MI Pilot
{% enddocs %}

{% docs column_sfdc_multi_tiered_account %}
Multi Tiered Account
{% enddocs %}

{% docs column_sfdc_name_with_lcom_organization_info %}
Name with LCOM Organization Info (A descriptive name for the Account with related information from the LCOM Organization.)
{% enddocs %}

{% docs column_sfdc_national_district_id %}
National District ID
{% enddocs %}

{% docs column_sfdc_national_school_id %}
National School ID
{% enddocs %}

{% docs column_sfdc_nc_tier_1 %}
NC Tier 1
{% enddocs %}

{% docs column_sfdc_nces_lea_id %}
NCES LEA Id
{% enddocs %}

{% docs column_sfdc_nces_unique_id %}
NCES Unique ID
{% enddocs %}


{% docs column_sfdc_netsuite_account_number %}
Netsuite Account Number (This will be mapped to Netsuite Customer ID for Customer object.)
{% enddocs %}


{% docs column_sfdc_nps_count %}
NPS Count (total number of NPS Surveys -to be used in NPS)
{% enddocs %}

{% docs column_sfdc_nps_score %}
NPS Score
{% enddocs %}

{% docs column_sfdc_nps_sum %}
NPS Sum (Combined sum NPS Survey Response object scores .   To be used in calculation of NPS)
{% enddocs %}

{% docs column_sfdc_num_opps %}
Number of opportunities (Number of opportunities)
{% enddocs %}

{% docs column_sfdc_number_of_2020_opps %}
Number of 2020 Opps
{% enddocs %}

{% docs column_sfdc_number_of_active_easy_tech_subscriptions %}
Number of Active EasyTech Subscriptions (Number of active EasyTech subscriptions. This is populated by a flow.)
{% enddocs %}

{% docs column_sfdc_number_of_active_vidcode_subscriptions %}
Number of Active Vidcode Subscriptions (Number of Active Vidcode Subscriptions. Populated by flow.)
{% enddocs %}

{% docs column_sfdc_number_of_elementary_schools %}
Number of Elementary Schools (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_number_of_high_schools %}
Number of High Schools (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_number_of_k_8_buildings %}
Number of K-8 Buildings
{% enddocs %}

{% docs column_sfdc_number_of_middle_schools %}
Number of Middle Schools (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_number_of_open_opportunities %}
Number of Open Opportunities
{% enddocs %}

{% docs column_sfdc_number_of_page_views %}
Number of Page Views
{% enddocs %}

{% docs column_sfdc_number_of_renewal_opps %}
Number of Renewal Opps (Roll up of the number of renewal opps associated with an account to be used for informing CSMs when a customer is approaching their first renewal with Learning.com)
{% enddocs %}

{% docs column_sfdc_number_of_schools %}
Number of Schools
{% enddocs %}

{% docs column_sfdc_number_of_sessions %}
Number of Sessions
{% enddocs %}

{% docs column_sfdc_number_of_title_i_schools %}
Number of Title I Schools
{% enddocs %}

{% docs column_sfdc_number_of_won_renewal_opportunities %}
Number of Won Renewal Opportunities (Denotes the number of won renewal opportunities at a given account. This field can be used to drive the 'Former Customer' value as well as to determine if the Renewal History dynamic related list field is surfaced on the account layout of former customers.)
{% enddocs %}

{% docs column_sfdc_open_opportunity_amount %}
Open Opportunity Amount (captures total amount of all open opps tied to an account)
{% enddocs %}

{% docs column_sfdc_open_renewal_opportunities %}
Open Renewal Opportunities (Denotes how many open renewal opportunities a given customer has. If count is >1, customer should be considered Active.  Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_org_type %}
Org Type - DO NOT USE for School/District. Use sfdc_record_type=L for districts and B for schools in SFDC
{% enddocs %}

{% docs column_sfdc_otc_provisioned %}
OTC Provisioned (checks the box if the otc provisioned date is not blank  Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_owner_id %}
Account Owner (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_owner_name_text %}
populated from SFDC User object Name attribute
{% enddocs %}

{% docs column_sfdc_parent_account_owner %}
Parent Account Owner
{% enddocs %}

{% docs column_sfdc_parent_and_child_match %}
Parent and Child match
{% enddocs %}

{% docs column_sfdc_parent_churned %}
Parent Churned
{% enddocs %}

{% docs column_sfdc_parent_et_tam %}
Parent ET TAM (Shows District ET TAM (used for building record customers)  Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_parent_gsid %}
Parent GSID
{% enddocs %}

{% docs column_sfdc_parent_id %}
Parent Account (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_parent_long_name %}
Parent Long Name
{% enddocs %}

{% docs column_sfdc_parent_mdr %}
Parent MDR
{% enddocs %}

{% docs column_sfdc_parent_name %}
Parent Name
{% enddocs %}

{% docs column_sfdc_parent_name_proper_case %}
Parent Name Proper Case
{% enddocs %}

{% docs column_sfdc_parent_owner_id %}
Parent Owner ID (18-digit Salesforce ID of the record owner)
{% enddocs %}

{% docs column_sfdc_parent_uid %}
Parent Agile ID
{% enddocs %}

{% docs column_sfdc_pct_afro_amer %}
Enrollment - Black (Percent) (Enrollment - Black (Percent))
{% enddocs %}

{% docs column_sfdc_pct_asian %}
Enrollment - Asian (Percent) (Enrollment - Asian (Percent))
{% enddocs %}

{% docs column_sfdc_pct_hisp %}
Enrollment - Hispanic (Percent)
{% enddocs %}

{% docs column_sfdc_pct_multi_racial %}
Enrollment - Multi Racial (Percent)
{% enddocs %}

{% docs column_sfdc_pct_native %}
Enrollment - Native American (Percent)
{% enddocs %}

{% docs column_sfdc_pct_white %}
Enrollment - White (Percent)
{% enddocs %}

{% docs column_sfdc_per_student_expenditures %}
Per Student Expenditures
{% enddocs %}

{% docs column_sfdc_percent_students_ell %}
Enrollment - ELL (Percent) (Enrollment - ELL (Percent))
{% enddocs %}

{% docs column_sfdc_phone %}
Phone (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_photo_url %}
Photo URL
{% enddocs %}

{% docs column_sfdc_platform_sync %}
Platform Sync
{% enddocs %}

{% docs column_sfdc_poverty_percent_under_age_18 %}
Poverty Percent Under Age 18
{% enddocs %}

{% docs column_sfdc_pre_k_enrollment %}
Pre-K Enrollment
{% enddocs %}

{% docs column_sfdc_priority_account %}
Priority Account
{% enddocs %}

{% docs column_sfdc_record_type %}
Record Type (L is for district and B is for school  Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_reduced_lunch_student %}
Reduced Lunch Student (Number of students eligible for reduced price lunch)
{% enddocs %}

{% docs column_sfdc_reference_customer %}
Reference Customer
{% enddocs %}

{% docs column_sfdc_related_activity %}
Related Activity
{% enddocs %}

{% docs column_sfdc_related %}
Related (Temporary. Indication that account has related Opportunity, Request, Case, or Activity.)
{% enddocs %}

{% docs column_sfdc_renewal_forecast_segment %}
Renewal Forecast Segment (Automatically assigns the correct renewal forecast segment based on current renewal ARR field.)
{% enddocs %}

{% docs column_sfdc_resa_name_proper %}
RESA Name Proper (Name of the RESA on Proper case. Populated by Agile)
{% enddocs %}

{% docs column_sfdc_resa_uid %}
RESA UID (Agile UID of the Regional Education Service Agency (RESA) associated with the district or school. Populated by Agile)
{% enddocs %}

{% docs column_sfdc_sales_owner_field %}
Sales Owner Field (Owner of upsell for an account  Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_sales_support_rep %}
Sales Support Rep (Sales Support Rep  Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_sbqq_co_termed_contracts_combined %}
Combine Co-Termed Contracts (Flag that controls whether assets and subscriptions from multiple co-teremed contracts are rolled up together. By default, each co-termed contract generates a separate group on renewal quote.)
{% enddocs %}

{% docs column_sfdc_sbqq_contract_co_termination %}
Contract Co-Termination (Determines how service and subscription contracts for this customer are co-terminated.)
{% enddocs %}

{% docs column_sfdc_sbqq_preserve_bundle %}
Preserve Bundle Structure (Select to maintain bundle hierarchy on renewal quotes and amendments)
{% enddocs %}

{% docs column_sfdc_school_enrollment %}
School Enrollment
{% enddocs %}

{% docs column_sfdc_school_type %}
School Type (This field is mapped and will sync with Agile/ConnectLink)
{% enddocs %}

{% docs column_sfdc_school_year_end %}
School Year End (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_school_year_start %}
School Year Start (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_schools_in_district %}
Schools in District (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_state_initiative %}
Boolean indicating if account is part of a state initiative. (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_state_profile %}
State Profile
{% enddocs %}

{% docs column_sfdc_state_program_eligible %}
State Program Eligible?
{% enddocs %}

{% docs column_sfdc_student_tam %}
Student TAM
{% enddocs %}

{% docs column_sfdc_sync_district %}
Syncing District? (Check this box if the customer syncs with Learning.com)
{% enddocs %}

{% docs column_sfdc_syncing_district %}
Syncing District
{% enddocs %}

{% docs column_sfdc_system_modstamp %}
System Modstamp
{% enddocs %}

{% docs column_sfdc_target_account %}
Target Account (target account field that will denote if a district has been designated a priority account as part of the territory planning process)
{% enddocs %}

{% docs column_sfdc_teachers_in_building %}
Teachers in Building
{% enddocs %}

{% docs column_sfdc_technology_equipment %}
Technology - Equipment
{% enddocs %}

{% docs column_sfdc_technology_index %}
Technology Index
{% enddocs %}

{% docs column_sfdc_technology_measure %}
Technology Measure
{% enddocs %}

{% docs column_sfdc_technology_supplies_and_purchases %}
Technology - Supplies and Purchases
{% enddocs %}

{% docs column_sfdc_territory %}
Territory
{% enddocs %}

{% docs column_sfdc_territory_list %}
Territory
{% enddocs %}

{% docs column_sfdc_test_account %}
Test Account (Denotes if the account should be excluded from business reporting and the account is only used for internal testing)
{% enddocs %}

{% docs column_sfdc_tiered_service_level %}
Tiered Service Level (3/20/20 - Need to delete or fix the associated flow. Hiding from profiles.)
{% enddocs %}

{% docs column_sfdc_title_iv_funding_21_st_century_grants %}
Title IV Funding (21st Century Grants)
{% enddocs %}

{% docs column_sfdc_top_75_account %}
Top 75 Account
{% enddocs %}

{% docs column_sfdc_total_credits_purchased %}
Total Credits Purchased (This is what they initially purchased for their subscription term. Manually decremented by the ECS team elsewhere.)
{% enddocs %}

{% docs column_sfdc_total_number_of_schools %}
Total Number of Schools
{% enddocs %}

{% docs column_sfdc_total_renewal_arr %}
Total Renewal ARR (A total of all Renewal ARR from account and child accounts.  Populated via Gainsight using the rule Rollup Renewal ARR  Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_trend_district_revenue %}
Trend District Revenue
{% enddocs %}

{% docs column_sfdc_trend_enrollment %}
Trend Enrollment
{% enddocs %}

{% docs column_sfdc_trend_federal_revenue %}
Trend Federal Revenue
{% enddocs %}

{% docs column_sfdc_trend_instructional_expenditures %}
Trend Instructional Expenditures
{% enddocs %}

{% docs column_sfdc_trend_local_revenue %}
Trend Local Revenue
{% enddocs %}

{% docs column_sfdc_trend_state_revenue %}
Trend State Revenue
{% enddocs %}

{% docs column_sfdc_trend_title_i_revenue %}
Trend Title I Revenue
{% enddocs %}

{% docs column_sfdc_type %}
Type
{% enddocs %}

{% docs column_sfdc_ultimate_account_owner %}
Ultimate Account Owner
{% enddocs %}

{% docs column_sfdc_ultimate_parent_account %}
ULTIMATE PARENT (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_ultimate_parent_billing_state %}
Ultimate Parent Billing State
{% enddocs %}

{% docs column_sfdc_ultimate_parent_id %}
Salesforce Id of Ultimate Parent
{% enddocs %}

{% docs column_sfdc_ultimate_parent_total_renewal_arr_2 %}
Ultimate Parent Total Renewal ARR (this is a currency formula field to lookup to the parent's field value of the Total Renewal ARR)
{% enddocs %}

{% docs column_sfdc_urban_rural %}
Urban Rural (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_vidcode_customer_2 %}
Vidcode Customer (Converts the Number of Active Vidcode Subscriptions field into a checkbox  Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_virtual_school %}
Virtual School
{% enddocs %}

{% docs column_sfdc_virtual_status_text %}
Virtual Status Text
{% enddocs %}

{% docs column_sfdc_website %}
Website (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_x_1_1_computing %}
1:1 Computing
{% enddocs %}

{% docs column_sfdc_x_10_th_grade_enrollment %}
10th Grade Enrollment (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_x_11_th_grade_enrollment %}
11th Grade Enrollment (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_x_12_th_grade_enrollment %}
12th Grade Enrollment (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_x_2_nd_grade_enrollment %}
2nd Grade Enrollment (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_x_2020_service_purchased %}
2020 Service Purchased (Denotes if customer purchased training for 2020 school year)
{% enddocs %}

{% docs column_sfdc_x_21_csa_eol %}
21CSA EOL (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_x_3_plms %}
3PLMS (Check this if the customer is using a third party learning managment system (LMS))
{% enddocs %}

{% docs column_sfdc_x_3_rd_grade_enrollment %}
3rd Grade Enrollment (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_x_4_th_grade_enrollment %}
4th Grade Enrollment (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_x_6_th_grade_enrollment %}
6th Grade Enrollment (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_x_7_th_grade_enrollment %}
7th Grade Enrollment (Integrations: Gainsight.)
{% enddocs %}

{% docs column_sfdc_x_9_th_grade_enrollment %}
9th Grade Enrollment (Integrations: Gainsight.)
{% enddocs %}s


{% docs column_SFDC_lcom_organization_id %}
LCom Organization linked to Salesforce account in Salesforce (Licensing project).
{% enddocs %}

{% docs column_sfdc_state_initiative_school %}
State Initiative from the child(school) level. True if any school has True attribute
{% enddocs %}

{% docs column_sfdc_district_state_initiative_school %}
District State Initiative from the child(school) level. True if any school has True attribute
{% enddocs %}

{% docs column_sfdc_state_initiative_district %}
State Initiative from the parent(district) level. True if parent`s attribute is True
{% enddocs %}

{% docs column_sfdc_district_state_initiative_district %}
District State Initiative from the parent(district) level. True if parent`s attribute is True
{% enddocs %}

{% docs column_ishighschool %}
For State progam reports where HS need to be excluded - Indicates if the school is a high school only. No middle or elementary grades. Salesforce Account grade_levels = 'High School' or (grade_levels is null and k_12_enrollment>0 and k_8_enrollment=0). For the most recent orders we should have all schools in the table linked to a Salesforce account if they have an order
{% enddocs %}

{% docs column_SFDC_ultimate_parent_current_renewal_arr %}
Aggregated current renewal ARR across all ultimate parent account child accounts.
{% enddocs %}