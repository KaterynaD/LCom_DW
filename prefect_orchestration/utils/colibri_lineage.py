# airflow/Utils/colibri_lineage.py
"""
colibri_lineage.py

Library helper for traversing Colibri-style column lineage.

Expected manifest structure:
{
  "lineage": {
    "edges": [
      {
        "id": 2226,
        "source": "source....",
        "target": "model....",
        "sourceColumn": "alt_phone_c",
        "targetColumn": "sfdc_alt_phone"
      },
      ...
    ]
  }
}

Public API:
  get_column_lineage(manifest_path: str, source: str, source_column: str, flg: str) -> dict

Output schema :
{
  "source": "<source parameter>",
  "source_column": "<source_column parameter>",
  "direct_usage": [ "<immediate model targets>", ... ],
  "downstream_usage": [ "<unique downstream model targets>", ... ],
  "error": "<string or empty>",
  "flg": "<flg parameter>"
}
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from collections import defaultdict
from typing import DefaultDict, Dict, Iterable, List, Optional, Set, Tuple


@dataclass(frozen=True)
class _Edge:
    edge_id: int
    source: str
    target: str
    source_col: str
    target_col: str


def _is_model(node: str) -> bool:
    return isinstance(node, str) and node.startswith("model.")


def _norm_col(col: str) -> str:
    # Column matching: case-insensitive by default (matches most dbt/warehouse behavior)
    return (col or "").strip().lower()


def _load_edges(manifest_path: Path) -> List[_Edge]:
    data = json.loads(manifest_path.read_text(encoding="utf-8"))

    lineage = data.get("lineage")
    if not isinstance(lineage, dict):
        raise ValueError("JSON does not contain an object at key 'lineage'")

    edges_raw = lineage.get("edges")
    if not isinstance(edges_raw, list):
        raise ValueError("JSON does not contain a list at key 'lineage.edges'")

    edges: List[_Edge] = []
    for e in edges_raw:
        if not isinstance(e, dict):
            continue

        edge_id = e.get("id")
        source = e.get("source")
        target = e.get("target")
        sc = e.get("sourceColumn", "")
        tc = e.get("targetColumn", "")

        if not isinstance(edge_id, int):
            continue
        if not isinstance(source, str) or not isinstance(target, str):
            continue
        if not isinstance(sc, str) or not isinstance(tc, str):
            continue

        sc_n = _norm_col(sc)
        tc_n = _norm_col(tc)

        # For column traversal we require both columns
        if not sc_n or not tc_n:
            continue

        edges.append(
            _Edge(
                edge_id=edge_id,
                source=source.strip(),
                target=target.strip(),
                source_col=sc_n,
                target_col=tc_n,
            )
        )

    return edges


def _build_index(edges: Iterable[_Edge]) -> Dict[Tuple[str, str], List[_Edge]]:
    idx: DefaultDict[Tuple[str, str], List[_Edge]] = defaultdict(list)
    for e in edges:
        idx[(e.source, e.source_col)].append(e)
    return dict(idx)


def _find_paths(
    idx: Dict[Tuple[str, str], List[_Edge]],
    start_node: str,
    start_col: str,
    max_depth: int = 50,
) -> List[List[Tuple[str, str]]]:
    """
    Paths are sequences of (node, col) pairs.
    Transition rule:
      (node, col) --edge--> (edge.target, edge.target_col)
    """
    start = (start_node.strip(), _norm_col(start_col))
    if not start[0] or not start[1]:
        return []

    paths: List[List[Tuple[str, str]]] = []
    stack: List[List[Tuple[str, str]]] = [[start]]

    while stack:
        path = stack.pop()
        cur_node, cur_col = path[-1]

        if (len(path) - 1) >= max_depth:
            paths.append(path)
            continue

        next_edges = idx.get((cur_node, cur_col), [])
        if not next_edges:
            paths.append(path)
            continue

        for e in next_edges:
            nxt = (e.target, e.target_col)
            # avoid cycles within the same path
            if nxt in path:
                continue
            stack.append(path + [nxt])

    return paths


def _first_model_in_path(path: List[Tuple[str, str]]) -> Optional[str]:
    # returns first model node encountered (excluding the start if it is not a model)
    for node, _col in path:
        if _is_model(node):
            return node
    return None


def _all_models_in_path(path: List[Tuple[str, str]]) -> List[str]:
    seen: Set[str] = set()
    out: List[str] = []
    for node, _col in path:
        if _is_model(node) and node not in seen:
            seen.add(node)
            out.append(node)
    return out


def get_column_lineage(manifest_path: str, source: str, source_column: str, flg: str) -> Dict[str, object]:
    """
    Main function requested by you.

    Output keys:
      - source
      - source_column
      - direct_usage
      - downstream_usage
      - error
      - flg (Missing or Empty)
    """
    result: Dict[str, object] = {
        "source": source,
        "source_column": source_column,
        "direct_usage": [],
        "downstream_usage": [],
        "error": "",
        "flg": flg,
    }

    try:
        mp = Path(manifest_path)
        if not mp.exists():
            result["error"] = f"ERROR: file not found: {manifest_path}"
            return result

        edges = _load_edges(mp)
        if not edges:
            result["error"] = "No usable column-level edges found (no edges with both sourceColumn and targetColumn)."
            return result

        idx = _build_index(edges)
        paths = _find_paths(idx, source, source_column)

        if not paths:
            result["error"] = "No paths found."
            return result

        direct_models: Set[str] = set()
        downstream_models: Set[str] = set()

        for path in paths:
            first_model = _first_model_in_path(path)
            if first_model:
                direct_models.add(first_model)

            models_in_path = _all_models_in_path(path)
            # everything after the first model is downstream for that path
            if first_model and first_model in models_in_path:
                i = models_in_path.index(first_model)
                for m in models_in_path[i + 1 :]:
                    downstream_models.add(m)

        if not direct_models and not downstream_models:
            result["error"] = "Paths found, but none reached any model.* nodes."
            return result

        # downstream must be unique and must NOT repeat direct models
        downstream_models -= direct_models

        result["direct_usage"] = sorted(direct_models)
        result["downstream_usage"] = sorted(downstream_models)
        return result

    except json.JSONDecodeError as e:
        result["error"] = f"ERROR: invalid JSON: {e}"
        return result
    except Exception as e:
        result["error"] = f"ERROR: {type(e).__name__}: {e}"
        return result
