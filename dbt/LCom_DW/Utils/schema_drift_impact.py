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
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "commissioner_of_ed_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "current_total_ultimate_parent_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "customer_health_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "customer_health_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_k_8_enrollment_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "governor_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "governor_s_party_affiliation_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "key_state_leaders_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "nps_score_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "nps_sum_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "national_district_id_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "national_school_id_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_classes_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_created_date_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_created_date_no_time_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_guid_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_highest_module_completion_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_highest_module_completion_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_i2c18_student_avg_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_i2c18_student_completion_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_i2c_student_avg_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_i2c_student_completion_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_id_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_initial_campaign_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_initial_medium_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_initial_source_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_lti_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_last_login_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_profile_city_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_profile_country_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_profile_school_code_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_profile_school_type_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_profile_school_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_profile_state_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_profile_zip_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_screen_name_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_social_auth_provider_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_students_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contact", "source_column": "codesters_url_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.contract", "source_column": "subscription_roll_up_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.creditmemo", "source_column": "netcreditsapplied"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.creditmemo", "source_column": "totaladjustmentamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.creditmemo", "source_column": "totalamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.creditmemo", "source_column": "totalamountwithtax"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.creditmemo", "source_column": "totalchargeamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.creditmemo", "source_column": "totaltaxamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.creditmemoinvapplication", "source_column": "impactamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.creditmemoline", "source_column": "lineamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.engagementsignalcmpndmetric", "source_column": "compoundmetricformula"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.invoice", "source_column": "netcreditsapplied"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.invoice", "source_column": "netpaymentsapplied"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.invoice", "source_column": "totaladjustmentamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.invoice", "source_column": "totalamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.invoice", "source_column": "totalamountwithtax"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.invoice", "source_column": "totalchargeamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.invoice", "source_column": "totaltaxamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.invoiceline", "source_column": "lineamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.lcom_organization__c", "source_column": "nces_id_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.lcom_organization__c", "source_column": "salesforce_account_parent_account_id_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.lcom_organization__c", "source_column": "salesforce_account_ult_parent_acct_id_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.lead", "source_column": "data_quality_description_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.lead", "source_column": "data_quality_description_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.lead", "source_column": "data_quality_description_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.lead", "source_column": "data_quality_description_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.lead", "source_column": "data_quality_score_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.lead", "source_column": "data_quality_score_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.lead", "source_column": "data_quality_score_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.lead", "source_column": "data_quality_score_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "integration_indicator_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "owner_closed_won_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "owner_open_pipeline_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "pipeline_needed_to_hit_quota_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "remaining_quota_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "set_up_for_processing_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunitylineitem", "source_column": "easycode_arr_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.payment", "source_column": "impactamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.payment", "source_column": "netpaymentcreditapplied"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.payment", "source_column": "netrefundapplied"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.payment", "source_column": "totalpaymentcreditapplied"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.payment", "source_column": "totalpaymentcreditunapplied"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.payment", "source_column": "totalrefundapplied"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.payment", "source_column": "totalrefundunapplied"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.paymentauthorization", "source_column": "totalauthreversalamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.paymentlineinvoice", "source_column": "effectiveimpactamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.paymentlineinvoice", "source_column": "impactamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.productcatalog", "source_column": "numberofcategories"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.productcategory", "source_column": "numberofproducts"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.refund", "source_column": "impactamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.refundlinepayment", "source_column": "effectiveimpactamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.refundlinepayment", "source_column": "impactamount"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.sbqq__quoteline__c", "source_column": "sbqq_componentvisibility_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.sbqq__quoteline__c", "source_column": "sbqq__effectiveenddate_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.sbqq__quoteline__c", "source_column": "sbqq__effectivestartdate_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.sbqq__quoteline__c", "source_column": "sbqq__effectivesubscriptionterm_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.sbqq__quote__c", "source_column": "lcom_order_lines_count_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.sbqq__quote__c", "source_column": "ultimate_parent_account_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.training_session__c", "source_column": "owner_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.codesters__opportunity_license__c", "source_column": "codesters__is_synced_match_c"},
{"source": "source.LCom_DW.fivetran_salesforce_quickstart.codesters__opportunity_license__c", "source_column": "codesters__is_synced_c"},
]

# INPUTS: List[Dict[str, Any]] = [
#  {"source": "model.LCom_DW.dim_account", "source_column": "sfdc_name"}
#  ]

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
