# dbt-schema-drift

Schema-drift–resilient dbt macros for source tables.



This module provides dbt macros that allow models to **continue running safely**
when source tables experience schema drift (columns disappearing
and later reappearing), without modifying dbt model SQL at runtime.

The macros dynamically substitute **typed default values** for missing columns
based on schema profiles, and automatically revert to using real columns when
they return.

---

## What Problem This Solves

Source tables may change daily:
- Columns can disappear without notice
- Downstream dbt models fail when referencing missing columns
- Engineers may not be available immediately to review the drift

These macros enable:
- **Non-failing dbt runs**
- **Explicit detection of missing columns**
- **Automatic recovery** when columns reappear
- **No mutation of dbt model files**

---

## Installation

Add to `packages.yml`:

```yml
packages:
  - git: https://github.com/kdrogaieva/dbt-schema-drift.git
    revision: v0.1.0
```

Run:

```bash
dbt deps
```

## Example: Using the macros in a dbt model

```sql
with sfdc_account as (
  select *
  from {{ source('sfdc','account') }}
)

select
  {{ safe_select_list_from_profiles(
      table_name='account',
      alias='sfdc_account',
      used_columns=[
        'id',
        'name',
        'billing_country',
        'district_enrollment_c'
      ],
      profile_src=('profiles','sfdc_schema_audit'),
      base_profile='base',
      current_profile='current'
  ) }}
from sfdc_account
```

## Before / After: Compiled SQL Example

### dbt run output when all expected columns are present

```sql
select
  sfdc_account.id as id,
  sfdc_account.name as name,
  sfdc_account.billing_country as billing_country,
  sfdc_account.district_enrollment_c as district_enrollment_c
from sfdc.account as sfdc_account
```

### dbt run output when `district_enrollment_c` is missing

```sql
select
  sfdc_account.id as id,
  sfdc_account.name as name,
  sfdc_account.billing_country as billing_country,
  0::numeric as district_enrollment_c
from sfdc.account as sfdc_account
```


## Provided Macros

### `missing_defaults_map`
Detects columns that are:
- present in the **base profile**
- missing in the **current profile**
- actually used by a specific dbt model

Returns a dictionary:

```jinja
{
  column_name: default_sql_expression
}
```

---

### `safe_select_list_from_profiles`
Builds a stable SELECT list for a dbt model by:
- using the real column if it exists today
- substituting a typed default if it is missing
- preserving the order of `used_columns`

This macro is intended to be used directly in dbt models.

---

## Expected Profile Table

The macros rely on a **profile table** that stores schema snapshots.
The **schema name and table name are configurable**, but the **column names are fixed**.

### Required Columns (Hard-coded in macros)

| Column name            | Description |
|-----------------------|-------------|
| `profile_name`        | Profile identifier (e.g. `base`, `current`) |
| `table_name`          | Source table name (e.g. `account`) |
| `column_name`         | Column name |
| `data_type`           | Raw data type (used for boolean detection) |
| `data_type_category`  | Normalized type category (`varchar`, `numeric`, `date`, etc.) |

### Required Profiles

| Profile name | Meaning |
|-------------|--------|
| `base`      | Expected / designed schema source table column set |
| `current`   | Latest snapshot of the source table, with possible missing columns |

---

## Example Profile Table Structure

```sql
create table profiles.sfdc_schema_audit (
    profile_name         varchar,
    table_name           varchar,
    column_name          varchar,
    data_type            varchar,
    data_type_category   varchar,
    profile_timestamp    timestamp
);
```

---

## Required dbt Variables (Defaults)

These **must** be defined in `dbt_project.yml`:

```yml
vars:
  default_varchar: "__MISSING__"
  default_numeric: 0
  default_date: "1900-01-01"
  default_boolean: false
```

---

## Execution Behavior

### Parse / Compile Phase (`execute == false`)
- No database queries are run
- Emits `alias.column AS column`
- Enables `dbt compile` and `dbt docs generate`

### Runtime Phase (`execute == true`)
- Profiles table is queried
- Missing columns are detected
- Typed defaults are substituted

---

## Recommended Operational Pattern

1. Maintain a **base schema profile**
2. Generate a **current profile** before nightly dbt runs
3. Alert engineers when drift is detected
4. Allow dbt runs to continue safely
5. Re-baseline profiles when schema changes are accepted

## License

MIT