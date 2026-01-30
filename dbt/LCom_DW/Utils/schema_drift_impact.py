#!/usr/bin/env python3
# airflow/Utils/run_colibri_lineage_batch.py

from __future__ import annotations

import json
from html import escape as html_escape
import sys
from pathlib import Path
from typing import Any, Dict, List

# ----------------------------
# VARIABLES (EDIT THESE)
# ----------------------------

MANIFEST_PATH = "../target/colibri-manifest.json"

INPUTS: List[Dict[str, Any]] = [
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "account_last_activity_date_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "account_management_type_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "act_id_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "actively_prospecting_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "activity_metric_id"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "activity_metric_rollup_id"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "ae_or_isr_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agile_id_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agile_lms_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_agile_ed_insert_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_agile_ed_key_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_agile_ed_latest_update_date_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_agile_ed_parent_key_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_agile_ed_status_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_agile_ed_up_to_date_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_agileed_do_not_update_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_connect_link_changed_personnel_titles_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_connect_link_district_key_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_connect_link_file_type_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_connect_link_hierarchized_personnel_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_connect_link_licensed_status_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_connect_link_personnel_roles_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_connect_link_personnel_titles_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_last_sync_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_parent_pending_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "agileed_personnel_last_sync_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "cares_act_allocation_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "closed_district_tx_adoption_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "code_monkey_customer_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "codester_id_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "codesters_account_to_be_migrated_to_prod_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "codesters_customer_2_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "codesters_customer_dedupe_flag_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "company_domain_name_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "completed_onboarding_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "computer_os_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "contracted_roll_up_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "csm_email_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "csm_name_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "current_total_ultimate_parent_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "detailed_grade_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_easy_code_tam_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_easy_tech_tam_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_elementary_teachers_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_expansion_potential_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_faculty_library_media_fte_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_instructional_expenditures_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_kindergarten_teachers_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_local_revenue_cities_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_local_revenue_other_leas_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_local_revenue_other_taxes_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_local_revenue_property_taxes_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_nces_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_presence_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_total_capital_outlay_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_total_expenditures_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_total_expense_per_student_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_total_fed_revenue_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_total_local_revenue_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_total_revenue_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_total_state_revenue_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_total_tam_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_type_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "dq_opportunities_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "easy_tech_customer_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "easy_tech_tam_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "easy_tech_tam_captured_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "ec_tam_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "education_climate_index_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "education_type_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "eighth_grade_enrollment_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "email_domain_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "enrollment_advanced_placement_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "enrollment_band_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "esser_funding_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "et_tam_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "exes_campaign_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "fifth_grade_enrollment_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "first_grade_enrollment_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "first_name_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "fiscal_career_and_tech_federal_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "fiscal_career_and_tech_state_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "fiscal_career_and_tech_teacher_salar_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "free_lunch_students_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "free_reduced_lunch_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "gainsight_customer_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "gainsight_house_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "google_integration_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "governor_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "governor_s_party_affiliation_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "grade_level_detail_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "has_codesters_child_accounts_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "hi_speed_classroom_internet_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "hi_speed_internet_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "hml_title_i_funding_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "hml_title_i_per_student_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "house_account_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "i_pad_schools_percent_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "i_pads_for_instruction_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "ima_coordinator_identified_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "inst_uid_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "k_8_district_presence_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "key_account_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "known_duplicate_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "last_activity_logged_on_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "learn_dash_code_sent_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "les_opp_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "license_consumption_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "map_tracker_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "mdr_number_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "mi_pilot_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "multi_tiered_account_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "national_district_id_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "national_school_id_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "nc_tier_1_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "nces_lea_id_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "nces_unique_id_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "netsuite_account_number_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "nps_count_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "nps_score_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "nps_sum_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "num_opps_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "number_of_2020_opps_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "number_of_active_easy_tech_subscriptions_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "number_of_active_vidcode_subscriptions_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "number_of_elementary_schools_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "number_of_high_schools_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "number_of_k_8_buildings_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "number_of_middle_schools_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "number_of_open_opportunities_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "number_of_page_views_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "number_of_renewal_opps_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "number_of_schools_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "number_of_sessions_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "number_of_title_i_schools_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "number_of_won_renewal_opportunities_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "open_opportunity_amount_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "open_renewal_opportunities_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "org_type_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "otc_provisioned_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "parent_and_child_match_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "parent_et_tam_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "parent_gsid_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "parent_long_name_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "parent_mdr_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "parent_name_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "parent_uid_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "pct_afro_amer_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "pct_asian_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "pct_hisp_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "pct_multi_racial_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "pct_native_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "pct_white_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "per_student_expenditures_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "percent_students_ell_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "photo_url"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "platform_sync_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "poverty_percent_under_age_18_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "priority_account_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "reduced_lunch_student_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "reference_customer_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "related_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "resa_name_proper_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "resa_uid_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "sales_support_rep_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "sbqq_co_termed_contracts_combined_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "sbqq_contract_co_termination_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "sbqq_preserve_bundle_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "school_type_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "school_year_end_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "school_year_start_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "schools_in_district_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "state_profile_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "student_tam_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "sync_district_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "syncing_district_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "system_modstamp"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "target_account_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "teachers_in_building_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "technology_equipment_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "technology_index_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "technology_measure_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "technology_supplies_and_purchases_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "territory_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "territory_list_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "tiered_service_level_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "top_75_account_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "total_credits_purchased_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "total_number_of_schools_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "total_renewal_arr_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "trend_district_revenue_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "trend_enrollment_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "trend_federal_revenue_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "trend_instructional_expenditures_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "trend_local_revenue_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "trend_state_revenue_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "trend_title_i_revenue_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "type"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "ultimate_parent_total_renewal_arr_2_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "vidcode_customer_2_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "virtual_school_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "virtual_status_text_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "website"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "x_1_1_computing_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "x_10_th_grade_enrollment_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "x_11_th_grade_enrollment_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "x_12_th_grade_enrollment_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "x_2_nd_grade_enrollment_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "x_2020_service_purchased_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "x_21_csa_eol_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "x_3_plms_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "x_3_rd_grade_enrollment_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "x_4_th_grade_enrollment_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "x_6_th_grade_enrollment_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "x_7_th_grade_enrollment_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "x_9_th_grade_enrollment_c"},
]


# output_format: "json" or "html"
OUTPUT_FORMAT = "html"

# If OUTPUT_FORMAT == "html", write html to file (and also print)
HTML_OUTPUT_FILE = "column_lineage_report.html"

# ----------------------------
# IMPLEMENTATION
# ----------------------------

from pathlib import Path

# Add ../../airflow/utils to PYTHONPATH
UTILS_DIR = (Path(__file__).resolve().parents[3] / "airflow" / "utils")

sys.path.insert(0, str(UTILS_DIR))

from colibri_lineage import get_column_lineage  # noqa: E402


def to_html_table(rows: List[Dict[str, Any]]) -> str:
    headers = ["source", "source_column", "direct_usage", "downstream_usage", "error"]

    def fmt_list(v: Any) -> str:
        if isinstance(v, list):
            return ", ".join(str(x) for x in v)
        return "" if v is None else str(v)

    parts: List[str] = []
    parts.append("<!doctype html>")
    parts.append("<html><head><meta charset='utf-8'>")
    parts.append("<title>Column Lineage Report</title>")
    parts.append(
        "<style>"
        "body{font-family:Arial, sans-serif; padding:16px}"
        "table{border-collapse:collapse; width:100%}"
        "th,td{border:1px solid #ccc; padding:8px; vertical-align:top}"
        "th{background:#f5f5f5; text-align:left}"
        ".err{color:#b00020; font-weight:600}"
        "</style>"
    )
    parts.append("</head><body>")
    parts.append("<h2>Column Lineage Report</h2>")
    parts.append("<table>")
    parts.append("<thead><tr>" + "".join(f"<th>{html_escape(h)}</th>" for h in headers) + "</tr></thead>")
    parts.append("<tbody>")

    for r in rows:
        tds: List[str] = []
        for h in headers:
            val = r.get(h, "")
            cell = fmt_list(val)
            if h == "error" and cell:
                tds.append(f"<td class='err'>{html_escape(cell)}</td>")
            else:
                tds.append(f"<td>{html_escape(cell)}</td>")
        parts.append("<tr>" + "".join(tds) + "</tr>")

    parts.append("</tbody></table>")
    parts.append("</body></html>")
    return "\n".join(parts)


def main() -> int:
    outputs: List[Dict[str, Any]] = []

    for item in INPUTS:
        source = str(item.get("source", "")).strip()
        source_column = str(item.get("source_column", "")).strip()
        outputs.append(get_column_lineage(MANIFEST_PATH, source, source_column))

    if OUTPUT_FORMAT.lower() == "json":
        print(json.dumps(outputs, ensure_ascii=False, indent=2))
        return 0

    if OUTPUT_FORMAT.lower() == "html":
        html = to_html_table(outputs)
        print(html)
        Path(HTML_OUTPUT_FILE).write_text(html, encoding="utf-8")
        return 0

    print(f"ERROR: Unknown OUTPUT_FORMAT={OUTPUT_FORMAT!r}. Use 'json' or 'html'.")
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
