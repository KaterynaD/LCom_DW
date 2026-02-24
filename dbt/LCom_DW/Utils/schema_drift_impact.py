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

# INPUTS: List[Dict[str, Any]] = [
# {"source": "source.LCom_DW.fivetran_salesforce_quickstart.account", "source_column": "district_k_8_enrollment_c"}
# ]

INPUTS: List[Dict[str, Any]] = [
 {"source": "model.LCom_DW.dim_account", "source_column": "sfdc_name"}
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
