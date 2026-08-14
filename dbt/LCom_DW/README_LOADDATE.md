# Load Date Design and Usage

It is recommended that all persisted LCom DW models include a `loaddate`
column with a **Pacific Time** timestamp.

`loaddate` helps to:

-   Reconcile transformation and data issues.
-   Identify data changed or refreshed by a specific batch load.
-   Detect stale or skipped tables.
-   Monitor DW load readiness.

`loaddate` represents the **DW batch load timestamp**, not a
source-system timestamp.

## dbt Configuration

A global variable is declared in `dbt_project.yml`:

``` yaml
vars:
  loaddate: "{{ set_loaddate() }}"
```

The `set_loaddate()` macro automatically generates `loaddate` when a
value is not explicitly supplied to a dbt run. This provides a default
for standalone or manual dbt executions.

## Orchestrated Loads

A nightly DW pipeline may contain multiple separate dbt runs by mart or
tag. If each run generates its own `loaddate`, tables belonging to the
same pipeline execution will have slightly different timestamps.

Therefore, for orchestrated loads, the recommended design is to generate
`loaddate` **once at the beginning of the pipeline**:

``` python
loaddate = set_loaddate()
```

and pass the same value to every dbt run:

``` bash
dbt run --select tag:revenue --exclude config.materialized:view \
  --vars '{"run_type": "Scheduled Prod run", "loaddate": "2026-08-12T15:39:03-07:00"}'
```

This gives all models loaded by the same orchestration a common batch
timestamp.

> **One orchestrated DW batch load should have one `loaddate`.**

## dbt Model

Use the variable in model SQL:

``` sql
,'{{ var("loaddate") }}'::timestamp as loaddate
```

and define it in the model contract:

``` yaml
- name: loaddate
  data_type: timestamp
  description: "{{ doc('column_loaddate') }}"
  constraints:
    - type: not_null
```

The timestamp is generated in Pacific Time. The UTC offset may be
`-07:00` or `-08:00` depending on daylight saving time.

## DW Tables Readiness

`loaddate` is used by the **DW Tables Readiness** Tableau report to
identify stale tables. Tables refreshed by the same orchestrated load
have the same `loaddate`, while an older value indicates that a table
may not have been refreshed during the current batch.
