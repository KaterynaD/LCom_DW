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
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "account_manager_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "account_name_email_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "activity_metric_id"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "already_booked_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "closed_won_date_time_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "codesters_has_licenses_synced_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "codesters_number_of_licenses_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "codesters_number_of_synced_licenses_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "codesters_order_to_be_extended_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "codesters_order_to_be_unenforced_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "codesters_renewal_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "deal_docs_completed_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "disable_odc_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "expected_new_business_arr_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "expected_revenue"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "fiscal"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "forecast_category"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "forecast_category_name"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "has_coding_discount_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "has_easy_tech_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "has_open_activity"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "has_opportunity_line_item"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "has_overdue_task"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "has_started_with_students_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "house_account_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "initial_interest_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "international_reseller_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "introduction_of_quote_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "is_closed"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "is_pd_resources_offered_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "is_won"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "jitterbit_fulfilled_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "last_stage_change_date"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "les_opp_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "migrated_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "multi_year_discussed_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "needs_analysis_conducted_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "next_step"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "no_integration_needed_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "number_of_products_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "odc_sent_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "opp_to_be_closed_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "order_unenforced_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "original_close_date_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "original_opp_owner_1_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "otc_email_sent_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "owner_closed_won_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "owner_open_pipeline_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "owner_quota_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "owner_role_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "owner_sales_quota_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "pd_scheduled_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "pd_services_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "pipeline_needed_to_hit_quota_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "platform_name_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "po_amount_matches_primary_quote_amount_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "po_hold_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "po_received_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "po_received_counter_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "po_received_date_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "primary_quote_approved_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "progressive_billing_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "purchase_level_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "purchase_level_number_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "push_count"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "pushed_out_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "quote_synced_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "rai_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "rebuilt_during_migration_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "references_provided_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "renewal_at_79_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "renewal_biz_trigger_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "renewal_owner_email_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "rep_says_go_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "reseller_class_for_les_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "risk_identified_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "risk_opportunity_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "sales_support_rep_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "sbqq_contracted_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "sbqq_ordered_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "sbqq_renewal_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "school_year_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "send_odc_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "set_initial_new_biz_arr_amount_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "set_up_for_processing_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "spring_promo_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "stakeholders_confirmed_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "subscription_term_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "success_plan_agreed_upon_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "success_plan_shared_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "total_credit_from_opp_product_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "total_opportunity_quantity"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "training_session_created_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "transacted_opp_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "validation_bypass_date_time_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "variance_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "vendor_of_choice_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "verbal_commitment_c"},
  {"source": "source.LCom_DW.fivetran_salesforce_quickstart.opportunity", "source_column": "x_18_for_12_c"}
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
