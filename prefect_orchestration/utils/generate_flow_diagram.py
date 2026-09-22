"""Generate Mermaid flow diagrams from Python flow source code.

Purpose:
    Provide developer tooling that turns supported Prefect flow patterns into a
    Mermaid diagram for documentation and review.

Requirements for successful visualization:

- The source file must be valid Python syntax.
- The target function name must exist
    (default: ``mapped_parallel_flow`` or whichever name you pass via ``--flow``).
- The target function should contain at least one recognized call pattern:
    - ``run_sequential_tasks(...)``
    - ``run_parallel_tasks(...)``
    - direct calls to locally defined ``@task`` functions
    - ``something.map(...)``
    - ``wait(...)``
    - ``send_flow_report(...)``
    - task-controlling ``if``/``else`` statements containing these patterns

If none of the recognized patterns are found, this script raises:

- ``No supported flow steps found ...``

How to run:

- ``python generate_flow_diagram.py``
    Uses defaults:
    - ``--source parallel_tasks_map.py``
    - ``--flow mapped_parallel_flow``
    - ``--output parallel_tasks_map.md``

- ``python generate_flow_diagram.py --source one_task_flow.py --flow run_dummy_task_flow --output one_task_flow.md``

CLI parameters:

- ``--source``
    Path to the Python file to analyze.

- ``--flow``
    Name of the flow function inside ``--source`` to parse.

- ``--output``
    Path to the output Markdown file that will contain the Mermaid diagram.

Production notes:
    This module is intended for documentation and analysis, not for runtime flow
    execution inside orchestration jobs.
"""

from __future__ import annotations

import argparse
import ast
from pathlib import Path
from typing import Any


UNKNOWN = object()


def _resolve_expr(
    expr: ast.AST,
    env: dict[str, Any],
) -> Any:
    """Resolve a limited subset of AST expressions into Python values."""
    if isinstance(expr, ast.Constant):
        return expr.value

    if isinstance(expr, ast.Name):
        return env.get(expr.id, UNKNOWN)

    if isinstance(expr, ast.List):
        values = [_resolve_expr(item, env) for item in expr.elts]
        if any(value is UNKNOWN for value in values):
            return UNKNOWN
        return values

    if isinstance(expr, ast.Tuple):
        values = [_resolve_expr(item, env) for item in expr.elts]
        if any(value is UNKNOWN for value in values):
            return UNKNOWN
        return tuple(values)

    return UNKNOWN


def _extract_task_names(tasks_value: Any) -> list[str]:
    """Extract task labels from a literal task collection."""
    if not isinstance(tasks_value, (list, tuple)):
        return []

    names: list[str] = []
    for item in tasks_value:
        if isinstance(item, (list, tuple)) and item:
            first = item[0]
            if isinstance(first, str):
                names.append(first)

    return names


def _call_name(call: ast.Call) -> str | None:
    """Return the simple name of a function or method call."""
    if isinstance(call.func, ast.Name):
        return call.func.id
    if isinstance(call.func, ast.Attribute):
        return call.func.attr
    return None


def _decorator_name(decorator: ast.AST) -> str | None:
    """Return the simple name of a function decorator."""
    if isinstance(decorator, ast.Call):
        decorator = decorator.func
    if isinstance(decorator, ast.Name):
        return decorator.id
    if isinstance(decorator, ast.Attribute):
        return decorator.attr
    return None


def _extract_task_definitions(tree: ast.Module) -> dict[str, str]:
    """Map locally defined Prefect task functions to their display labels."""
    task_labels: dict[str, str] = {}

    for node in tree.body:
        if not isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            continue

        task_decorator = next(
            (
                decorator
                for decorator in node.decorator_list
                if _decorator_name(decorator) == "task"
            ),
            None,
        )
        if task_decorator is None:
            continue

        label = node.name.replace("_", " ").title()
        if isinstance(task_decorator, ast.Call):
            for keyword in task_decorator.keywords:
                if (
                    keyword.arg == "task_run_name"
                    and isinstance(keyword.value, ast.Constant)
                    and isinstance(keyword.value.value, str)
                ):
                    label = keyword.value.value
                    break

        task_labels[node.name] = label

    return task_labels


def _extract_standalone_task_label(
    call: ast.Call,
    task_labels: dict[str, str],
) -> str | None:
    """Return the label for a direct call to a locally defined Prefect task."""
    function_name: str | None = None

    if isinstance(call.func, ast.Name):
        function_name = call.func.id
    elif (
        isinstance(call.func, ast.Attribute)
        and call.func.attr in {"submit", "delay"}
        and isinstance(call.func.value, ast.Name)
    ):
        function_name = call.func.value.id

    if function_name is None:
        return None

    return task_labels.get(function_name)


def _extract_prefect_variable(expr: ast.AST) -> tuple[str, bool] | None:
    """Extract the Prefect variable controlling a task's run_enabled value."""
    for call in ast.walk(expr):
        if not isinstance(call, ast.Call):
            continue
        if _call_name(call) != "get_variable_as_bool" or not call.args:
            continue

        variable_name = call.args[0]
        if not (
            isinstance(variable_name, ast.Constant)
            and isinstance(variable_name.value, str)
        ):
            continue

        inverted = isinstance(expr, ast.UnaryOp) and isinstance(expr.op, ast.Not)
        return variable_name.value, inverted

    return None


def _extract_task_label(item: ast.AST) -> str | None:
    """Build a task label, including its run_enabled Prefect variable."""
    if not isinstance(item, (ast.Tuple, ast.List)) or not item.elts:
        return None

    name_expr = item.elts[0]
    if not (
        isinstance(name_expr, ast.Constant)
        and isinstance(name_expr.value, str)
    ):
        return None

    task_name = name_expr.value
    if len(item.elts) < 2:
        return task_name

    for call in ast.walk(item.elts[1]):
        if not isinstance(call, ast.Call):
            continue
        for keyword in call.keywords:
            if keyword.arg != "run_enabled":
                continue

            dependency = _extract_prefect_variable(keyword.value)
            if dependency is None:
                return task_name

            variable_name, inverted = dependency
            condition = f"not {variable_name}" if inverted else variable_name
            return f"{task_name}<br/>Depends on Prefect variable: {condition}"

    return task_name


def _extract_task_names_from_expr(
    expr: ast.AST,
    env_expr: dict[str, ast.AST],
) -> list[str]:
    """Extract task labels from an AST expression or referenced assignment."""
    if isinstance(expr, ast.Name):
        referenced = env_expr.get(expr.id)
        if referenced is None:
            return []
        return _extract_task_names_from_expr(referenced, env_expr)

    if isinstance(expr, ast.List):
        source_items = expr.elts
    elif isinstance(expr, ast.Tuple):
        source_items = expr.elts
    else:
        return []

    names: list[str] = []
    for item in source_items:
        label = _extract_task_label(item)
        if label is not None:
            names.append(label)

    return names


def _extract_runner_task_names(
    call: ast.Call,
    env: dict[str, Any],
    env_expr: dict[str, ast.AST],
) -> list[str]:
    """Resolve the task names passed to a runner helper call."""
    if not call.args:
        return []

    task_names = _extract_task_names_from_expr(call.args[0], env_expr)

    if task_names:
        return task_names

    tasks_value = _resolve_expr(call.args[0], env)
    return _extract_task_names(tasks_value)


def _extract_parallel_branches_from_expr(
    expr: ast.AST,
    env_expr: dict[str, ast.AST],
) -> list[list[str]]:
    """Extract parallel branches from a run_parallel_tasks argument.

    Returns a list of branches where each branch is a list of task names
    (sequential within that branch). Branches themselves run in parallel.

    Recognised formats:
      - ``(task_name, ...)``        → single-task branch
      - ``[(task_name, ...), ...]`` → sequential branch (list of tuples)
    """
    if isinstance(expr, ast.Name):
        referenced = env_expr.get(expr.id)
        if referenced is None:
            return []
        return _extract_parallel_branches_from_expr(referenced, env_expr)

    if not isinstance(expr, ast.List):
        return []

    branches: list[list[str]] = []
    for item in expr.elts:
        if isinstance(item, ast.Tuple):
            label = _extract_task_label(item)
            if label is not None:
                branches.append([label])
        elif isinstance(item, ast.List):
            branch_tasks: list[str] = []
            for sub_item in item.elts:
                label = _extract_task_label(sub_item)
                if label is not None:
                    branch_tasks.append(label)
            if branch_tasks:
                branches.append(branch_tasks)

    return branches


def _extract_mapped_labels(call: ast.Call, env: dict[str, Any]) -> list[str]:
    """Build readable labels for mapped task invocations."""
    task_label = "mapped_task"

    if isinstance(call.func, ast.Attribute):
        if isinstance(call.func.value, ast.Name):
            task_label = call.func.value.id
        else:
            task_label = ast.unparse(call.func.value)

    print_count_expr = None
    for keyword in call.keywords:
        if keyword.arg == "print_count":
            print_count_expr = keyword.value
            break

    if print_count_expr is None and call.args:
        print_count_expr = call.args[0]

    if print_count_expr is None:
        return [f"{task_label}.map(...)"]

    resolved_counts = _resolve_expr(print_count_expr, env)

    if isinstance(resolved_counts, (list, tuple)):
        labels: list[str] = []
        for count in resolved_counts:
            labels.append(f"{task_label}({count})")
        return labels

    return [f"{task_label}.map(...)"]


def _extract_call_step(
    call: ast.Call,
    env: dict[str, Any],
    env_expr: dict[str, ast.AST],
) -> dict[str, Any] | None:
    """Convert a supported orchestration call into a diagram step."""
    if isinstance(call.func, ast.Name) and call.func.id == "run_sequential_tasks":
        task_names = _extract_runner_task_names(call, env, env_expr)
        if task_names:
            return {
                "type": "sequential",
                "tasks": task_names,
            }

    if isinstance(call.func, ast.Name) and call.func.id == "run_parallel_tasks":
        branches = (
            _extract_parallel_branches_from_expr(call.args[0], env_expr)
            if call.args
            else []
        )
        if branches:
            return {
                "type": "parallel",
                "branches": branches,
            }

        task_names = _extract_runner_task_names(call, env, env_expr)
        if task_names:
            return {
                "type": "parallel",
                "tasks": task_names,
            }

    if isinstance(call.func, ast.Name) and call.func.id == "wait":
        return {"type": "wait"}

    if isinstance(call.func, ast.Name) and call.func.id == "send_flow_report":
        return {"type": "report", "label": "Send flow report"}

    return None


def _is_none_initialization_if(stmt: ast.If) -> tuple[str, ast.Assign] | None:
    """Identify ``if name is None: name = ...`` initialization blocks."""
    if not isinstance(stmt.test, ast.Compare):
        return None

    compare = stmt.test
    if not (
        isinstance(compare.left, ast.Name)
        and len(compare.ops) == 1
        and isinstance(compare.ops[0], ast.Is)
        and len(compare.comparators) == 1
        and isinstance(compare.comparators[0], ast.Constant)
        and compare.comparators[0].value is None
    ):
        return None

    name = compare.left.id
    for nested in stmt.body:
        if not isinstance(nested, ast.Assign):
            continue
        if any(
            isinstance(target, ast.Name) and target.id == name
            for target in nested.targets
        ):
            return name, nested

    return None


def _extract_steps_from_statements(
    statements: list[ast.stmt],
    env: dict[str, Any],
    env_expr: dict[str, ast.AST],
    source_code: str,
    task_labels: dict[str, str],
) -> list[dict[str, Any]]:
    """Extract diagram steps recursively from a sequence of statements."""
    steps: list[dict[str, Any]] = []

    for stmt in statements:
        if isinstance(stmt, ast.Assign):
            if isinstance(stmt.value, ast.Call):
                call = stmt.value
                if isinstance(call.func, ast.Attribute) and call.func.attr == "map":
                    steps.append({
                        "type": "parallel",
                        "tasks": _extract_mapped_labels(call, env),
                    })
                else:
                    task_label = _extract_standalone_task_label(call, task_labels)
                    if task_label is not None:
                        steps.append({
                            "type": "standalone",
                            "label": task_label,
                        })

            value = _resolve_expr(stmt.value, env)
            for target in stmt.targets:
                if isinstance(target, ast.Name):
                    env[target.id] = value
                    env_expr[target.id] = stmt.value
            continue

        if isinstance(stmt, ast.If):
            initialization = _is_none_initialization_if(stmt)
            if initialization is not None:
                name, assignment = initialization
                if env.get(name, UNKNOWN) is None:
                    env[name] = _resolve_expr(assignment.value, env)
                    env_expr[name] = assignment.value
                continue

            true_steps = _extract_steps_from_statements(
                stmt.body,
                env.copy(),
                env_expr.copy(),
                source_code,
                task_labels,
            )
            false_steps = _extract_steps_from_statements(
                stmt.orelse,
                env.copy(),
                env_expr.copy(),
                source_code,
                task_labels,
            )

            if true_steps or false_steps:
                condition = ast.get_source_segment(source_code, stmt.test)
                if condition is None:
                    condition = ast.unparse(stmt.test)
                steps.append({
                    "type": "decision",
                    "condition": " ".join(condition.split()),
                    "true_steps": true_steps,
                    "false_steps": false_steps,
                })
            continue

        if isinstance(stmt, ast.Expr) and isinstance(stmt.value, ast.Call):
            step = _extract_call_step(stmt.value, env, env_expr)
            if step is None:
                task_label = _extract_standalone_task_label(
                    stmt.value,
                    task_labels,
                )
                if task_label is not None:
                    step = {
                        "type": "standalone",
                        "label": task_label,
                    }
            if step is not None:
                steps.append(step)

    return steps


def _extract_flow_steps(
    source_code: str,
    flow_name: str,
) -> list[dict[str, Any]]:
    """Parse supported orchestration steps from a flow function source file."""
    tree = ast.parse(source_code)
    task_labels = _extract_task_definitions(tree)

    flow_function = None
    for node in tree.body:
        if isinstance(node, ast.FunctionDef) and node.name == flow_name:
            flow_function = node
            break

    if flow_function is None:
        raise ValueError(f"Flow function '{flow_name}' not found")

    env: dict[str, Any] = {}
    env_expr: dict[str, ast.AST] = {}

    arg_names = [arg.arg for arg in flow_function.args.args]
    defaults = flow_function.args.defaults
    first_default_index = len(arg_names) - len(defaults)

    for index, arg_name in enumerate(arg_names):
        if index >= first_default_index:
            default_expr = defaults[index - first_default_index]
            env[arg_name] = _resolve_expr(default_expr, env)
        else:
            env[arg_name] = UNKNOWN

    return _extract_steps_from_statements(
        flow_function.body,
        env,
        env_expr,
        source_code,
        task_labels,
    )


def _build_mermaid_from_steps(steps: list[dict[str, Any]]) -> str:
    """Build a Mermaid graph from flow steps.

    Uses a two-pass approach:
      1. Collect node labels and edges without emitting anything.
      2. Emit edges with labels inlined on the first use of each node ID,
         so no standalone node declarations appear before their connecting edges.
         Only true root nodes (no incoming edges) are emitted as standalone
         declarations at the top.
    """
    node_labels: dict[str, str] = {}
    node_shapes: dict[str, str] = {}
    edges: list[tuple[str, str, str | None]] = []

    node_counter = 1

    def next_node_id(prefix: str = "N") -> str:
        nonlocal node_counter
        node_id = f"{prefix}{node_counter}"
        node_counter += 1
        return node_id

    def connect(
        source_nodes: list[str],
        destination_node: str,
        label: str | None = None,
    ) -> None:
        for source_node in source_nodes:
            edges.append((source_node, destination_node, label))

    def label_decision_edges(
        decision_node: str,
        first_edge_index: int,
        label: str,
    ) -> None:
        for index in range(first_edge_index, len(edges)):
            source, destination, edge_label = edges[index]
            if source == decision_node and edge_label is None:
                edges[index] = (source, destination, label)

    def process_steps(
        nested_steps: list[dict[str, Any]],
        starting_nodes: list[str],
    ) -> list[str]:
        previous_nodes = starting_nodes

        for step in nested_steps:
            step_type = step["type"]

            if step_type == "sequential":
                task_ids: list[str] = []
                for task_name in step["tasks"]:
                    node_id = next_node_id("S")
                    node_labels[node_id] = task_name
                    task_ids.append(node_id)

                for index, node_id in enumerate(task_ids):
                    if index == 0:
                        connect(previous_nodes, node_id)
                    else:
                        connect([task_ids[index - 1]], node_id)

                if task_ids:
                    previous_nodes = [task_ids[-1]]
                continue

            if step_type == "parallel":
                if "branches" in step:
                    branch_end_nodes: list[str] = []
                    for branch_tasks in step["branches"]:
                        branch_node_ids: list[str] = []
                        for task_name in branch_tasks:
                            node_id = next_node_id("P")
                            node_labels[node_id] = task_name
                            branch_node_ids.append(node_id)

                        for index, node_id in enumerate(branch_node_ids):
                            if index == 0:
                                connect(previous_nodes, node_id)
                            else:
                                connect([branch_node_ids[index - 1]], node_id)

                        if branch_node_ids:
                            branch_end_nodes.append(branch_node_ids[-1])

                    previous_nodes = branch_end_nodes or previous_nodes
                else:
                    flat_ids: list[str] = []
                    for task_name in step.get("tasks", []):
                        node_id = next_node_id("P")
                        node_labels[node_id] = task_name
                        flat_ids.append(node_id)

                    for node_id in flat_ids:
                        connect(previous_nodes, node_id)

                    previous_nodes = flat_ids or previous_nodes
                continue

            if step_type == "decision":
                decision_id = next_node_id("D")
                node_labels[decision_id] = step["condition"]
                node_shapes[decision_id] = "decision"
                connect(previous_nodes, decision_id)

                branch_end_nodes: list[str] = []
                for branch_name, branch_key in (
                    ("True", "true_steps"),
                    ("False", "false_steps"),
                ):
                    branch_steps = step[branch_key]
                    if branch_steps:
                        first_edge_index = len(edges)
                        ends = process_steps(branch_steps, [decision_id])
                        label_decision_edges(
                            decision_id,
                            first_edge_index,
                            branch_name,
                        )
                        branch_end_nodes.extend(ends)
                    else:
                        continue_id = next_node_id("C")
                        node_labels[continue_id] = "Continue"
                        connect([decision_id], continue_id, branch_name)
                        branch_end_nodes.append(continue_id)

                previous_nodes = branch_end_nodes
                continue

            if step_type == "standalone":
                node_id = next_node_id("T")
                node_labels[node_id] = step["label"]
                connect(previous_nodes, node_id)
                previous_nodes = [node_id]
                continue

            if step_type == "wait":
                node_id = next_node_id("W")
                node_labels[node_id] = "wait(all mapped tasks)"
                connect(previous_nodes, node_id)
                previous_nodes = [node_id]
                continue

            if step_type == "report":
                node_id = next_node_id("R")
                node_labels[node_id] = step.get("label", "Send flow report")
                connect(previous_nodes, node_id)
                previous_nodes = [node_id]

        return previous_nodes

    process_steps(steps, [])

    def fmt(node_id: str) -> str:
        if node_id in labeled:
            return node_id
        labeled.add(node_id)
        escaped = node_labels[node_id].replace('"', "'")
        if node_shapes.get(node_id) == "decision":
            return f'{node_id}{{"{escaped}"}}'
        return f'{node_id}["{escaped}"]'

    lines = ["```mermaid", "graph TD"]
    labeled: set[str] = set()

    dst_ids = {dst for _, dst, _ in edges}
    for node_id in node_labels:
        if node_id not in dst_ids:
            lines.append(f"    {fmt(node_id)}")

    for src, dst, edge_label in edges:
        arrow = f"-->|{edge_label}|" if edge_label is not None else "-->"
        lines.append(f"    {fmt(src)} {arrow} {fmt(dst)}")

    lines.append("```")
    return "\n".join(lines)


def generate_flow_diagram_markdown(
    source_file: Path,
    flow_name: str,
) -> str:
    """Generate Markdown containing a Mermaid diagram for a flow."""
    source_code = source_file.read_text(encoding="utf-8")
    steps = _extract_flow_steps(source_code, flow_name)

    if not steps:
        raise ValueError(
            f"No supported flow steps found in '{flow_name}'. "
            "Expected run_sequential_tasks(...), run_parallel_tasks(...), map(...), wait(...), or send_flow_report(...)."
        )

    mermaid = _build_mermaid_from_steps(steps)

    return "\n".join([
        f"# Flow diagram for `{flow_name}`",
        "",
        "Generated automatically from source code.",
        "",
        mermaid,
        "",
    ])


def main() -> None:
    """Run the command-line interface for diagram generation."""
    parser = argparse.ArgumentParser(
        description="Generate a Mermaid flow diagram markdown from a Prefect flow function.",
    )
    parser.add_argument(
        "--source",
        default="parallel_tasks_map.py",
        help="Path to the Python source file containing the flow function.",
    )
    parser.add_argument(
        "--flow",
        default="mapped_parallel_flow",
        help="Flow function name to analyze.",
    )
    parser.add_argument(
        "--output",
        default="parallel_tasks_map.md",
        help="Markdown output file path.",
    )

    args = parser.parse_args()

    source_file = Path(args.source)
    output_file = Path(args.output)

    markdown = generate_flow_diagram_markdown(source_file, args.flow)
    output_file.write_text(markdown, encoding="utf-8", newline="\n")

    print(f"Diagram written to: {output_file.resolve()}")


if __name__ == "__main__":
    main()
